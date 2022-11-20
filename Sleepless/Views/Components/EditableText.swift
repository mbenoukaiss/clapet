import SwiftUI

@available(macOS 10.15, *)
public struct EditableText: View {
    @Binding var text: String
    @State private var newValue: String = ""
    
    @State var editProcessGoing = false { didSet{ newValue = text } }
    
    let onEditEnd: () -> Void
    
    public init(_ txt: Binding<String>, onEditEnd: @escaping () -> Void) {
        _text = txt
        self.onEditEnd = onEditEnd
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            Text(text)
                .multilineTextAlignment(.leading)
                .opacity(editProcessGoing ? 0 : 1)
            
            TextField("", text: $newValue,
                      onEditingChanged: { _ in },
                      onCommit: { text = newValue; editProcessGoing = false; onEditEnd() }
            )
            .opacity(editProcessGoing ? 1 : 0)
            .multilineTextAlignment(.center)
        }
        .onTapGesture(count: 2, perform: { editProcessGoing = true } )
        .onExitCommand(perform: { editProcessGoing = false; newValue = text })
    }
}
