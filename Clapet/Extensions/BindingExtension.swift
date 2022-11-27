import SwiftUI

extension Binding {
    
    func toOptional(_ defaultValue: Value) -> Binding<Value?> {
        Binding<Value?>(
            get: { wrappedValue },
            set: { wrappedValue = $0 ?? defaultValue }
        )
    }
    
    static func ?? <Wrapped>(optional: Self, defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
        Binding<Wrapped>(
            get: { optional.wrappedValue ?? defaultValue },
            set: { optional.wrappedValue = $0 }
        )
    }
    
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue
                handler(newValue)
            }
        )
    }
    
}
