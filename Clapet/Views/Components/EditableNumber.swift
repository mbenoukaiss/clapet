import SwiftUI

@available(macOS 10.15, *)
public struct EditableNumber: View {
    
    @Binding
    var placeholder: String?
    
    @Binding
    var number: Int?
    
    @State
    private var newValue: Int?
    
    @FocusState
    var isEditing {
        didSet { newValue = number }
    }
    
    let formatter: ((Int) -> String)?
    let validator: ((Int?) -> String?)?
    
    public init(_ number: Binding<Int>, placeholder: Binding<String?>? = nil, formatter: ((Int) -> String)? = nil, validator: ((Int?) -> String?)? = nil) {
        self._number = number.toOptional(0)
        self._placeholder = placeholder ?? .constant(nil)
        self.newValue = number.wrappedValue
        self.formatter = formatter
        self.validator = validator
    }
    
    public init(_ number: Binding<Int?>, placeholder: Binding<String?>? = nil, formatter: ((Int) -> String)? = nil, validator: ((Int?) -> String?)? = nil) {
        self._number = number
        self._placeholder = placeholder ?? .constant(nil)
        self.newValue = number.wrappedValue
        self.formatter = formatter
        self.validator = validator
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            //makes the whole line respond to onTapGesture
            //when in display mode because text doesn't expand
            Rectangle().opacity(0.001)
            
            Text(number != nil ? formatter?(number.unsafelyUnwrapped) ?? String(number.unsafelyUnwrapped) : placeholder ?? "empty".localize())
                .multilineTextAlignment(.leading)
                .italic(number == nil)
                .opacity(isEditing ? 0 : 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            NumberField("", value: $newValue)
                .onSubmit { stopEditing(true) }
                .opacity(isEditing ? 1 : 0)
                .multilineTextAlignment(.leading)
                .focused($isEditing)
                .frame(maxWidth: .infinity)
        }
        .onTapGesture(count: 2, perform: { isEditing = true } )
        .onExitCommand(perform: { stopEditing(false) })
    }
    
    func stopEditing(_ successful: Bool) {
        if successful {
            if let validator = validator {
                if let error = validator(newValue) {
                    let alert = NSAlert()
                    alert.messageText = "invalid-input".localize()
                    alert.informativeText = error
                    alert.addButton(withTitle: "cancel".localize())
                    alert.alertStyle = .warning
                    alert.runModal()
                    
                    return
                }
            }
            
            number = newValue
        } else {
            newValue = number
        }
        
        isEditing = false
    }
    
}
