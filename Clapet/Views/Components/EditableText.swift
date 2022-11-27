import SwiftUI

@available(macOS 10.15, *)
public struct EditableText: View {
    
    @Binding
    var text: String?
    
    @State
    private var newValue: String?
    
    @FocusState
    var isEditing {
        didSet { newValue = text }
    }
    
    let formatter: ((String) -> String)?
    let validator: ((String?) -> String?)?
    
    public init(_ text: Binding<String>, formatter: ((String) -> String)? = nil, validator: ((String?) -> String?)? = nil) {
        self._text = text.toOptional("")
        self.newValue = text.wrappedValue
        self.formatter = formatter
        self.validator = validator
    }
    
    public init(_ text: Binding<String?>, formatter: ((String) -> String)? = nil, validator: ((String?) -> String?)? = nil) {
        self._text = text
        self.newValue = text.wrappedValue
        self.formatter = formatter
        self.validator = validator
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            //makes the whole line respond to onTapGesture
            //when in display mode because text doesn't expand
            Rectangle().opacity(0.001)
            
            Text(text == nil ? "empty".localize() : (formatter != nil ? formatter.unsafelyUnwrapped(text.unsafelyUnwrapped) : text.unsafelyUnwrapped))
                .multilineTextAlignment(.leading)
                .italic(text == nil)
                .opacity(isEditing ? 0 : 1)
            
            TextField("", text: $newValue ?? "")
                .onSubmit { stopEditing(true) }
                .opacity(isEditing ? 1 : 0)
                .multilineTextAlignment(.center)
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
            
            text = newValue == "" ? nil : newValue
        } else {
            newValue = text
        }
        
        isEditing = false
    }
    
}
