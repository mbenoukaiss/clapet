import Combine
import SwiftUI

struct NumberField: View {
    
    private let label: LocalizedStringKey
    
    private let binding: Binding<Int>
    
    init(_ label: LocalizedStringKey, value: Binding<Int>) {
        self.label = label
        self.binding = value
    }
    
    var body: some View {
        TextField(label, text: Binding(
            get: { String(binding.wrappedValue) },
            set: {
                self.binding.wrappedValue = Int($0.filter { "0123456789".contains($0) }) ?? 0
            }
        ))
    }
}
