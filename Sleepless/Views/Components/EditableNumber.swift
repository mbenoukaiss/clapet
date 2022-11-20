import SwiftUI

@available(macOS 10.15, *)
public struct EditableNumber: View {
    @Binding
    var number: Int?
    
    @State
    private var newValue: Int?
    
    @State
    var isEditing = false {
        didSet { newValue = number }
    }
    
    let formatter: (Int) -> String
    let validator: ((Int?) -> String?)?
    
    public init(_ number: Binding<Int>, formatter: @escaping (Int) -> String) {
        self._number = number.toOptional(0)
        self.newValue = number.wrappedValue
        self.formatter = formatter
        self.validator = nil
    }
    
    public init(_ number: Binding<Int?>, formatter: @escaping (Int) -> String) {
        self._number = number
        self.newValue = number.wrappedValue
        self.formatter = formatter
        self.validator = nil
    }
    
    public init(_ number: Binding<Int>, formatter: @escaping (Int) -> String, validator: @escaping (Int?) -> String?) {
        self._number = number.toOptional(0)
        self.newValue = number.wrappedValue
        self.formatter = formatter
        self.validator = validator
    }
    
    public init(_ number: Binding<Int?>, formatter: @escaping (Int) -> String, validator: @escaping (Int?) -> String?) {
        self._number = number
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
            
            Text(number == nil ? "Double click to edit" : formatter(number.unsafelyUnwrapped))
                .multilineTextAlignment(.leading)
                .opacity(isEditing ? 0 : 1)
            
            NumberField("", value: $newValue)
                .onSubmit { stopEditing(true) }
                .opacity(isEditing ? 1 : 0)
                .multilineTextAlignment(.center)
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
                    alert.messageText = "Invalid input"
                    alert.informativeText = error
                    alert.addButton(withTitle: "Cancel")
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
