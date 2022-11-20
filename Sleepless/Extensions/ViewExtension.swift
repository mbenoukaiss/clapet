import SwiftUI

extension View {
    func asHint() -> some View {
        return self
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.gray)
    }
}
