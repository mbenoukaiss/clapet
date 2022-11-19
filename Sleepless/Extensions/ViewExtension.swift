import SwiftUI

extension View {
    func hint() -> some View {
        return self
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.gray)
    }
}
