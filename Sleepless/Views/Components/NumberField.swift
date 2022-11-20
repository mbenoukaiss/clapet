import Combine
import SwiftUI

struct NumberField: View {
    
    private let label: LocalizedStringKey
    
    private let binding: Binding<Int?>
    
    public init(_ label: LocalizedStringKey, value: Binding<Int?>) {
        self.label = label
        self.binding = value
    }
    
    public init(_ label: LocalizedStringKey, value: Binding<Int>) {
        self.label = label
        self.binding = value.toOptional(0)
    }
    
    var body: some View {
        TextField(label, text: Binding(
            get: {
                if let value = binding.wrappedValue {
                    return String(value)
                } else {
                    return String()
                }
            },
            set: {
                self.binding.wrappedValue = Int($0.filter { "0123456789".contains($0) }) ?? 0
            }
        ))
    }
    
}
