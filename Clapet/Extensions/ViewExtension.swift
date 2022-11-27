import SwiftUI

extension View {
    
    func asHint() -> some View {
        self.font(.system(size: 11, weight: .regular))
            .foregroundColor(.gray)
    }
    
}
