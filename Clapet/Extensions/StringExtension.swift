import Foundation

extension String {
    
    func localize(_ args: [CVarArg]) -> String {
        String(
            format: NSLocalizedString(self, comment: ""),
            args
        )
    }
    
    func localize(_ args: CVarArg...) -> String {
        String(
            format: NSLocalizedString(self, comment: ""),
            args
        )
    }
    
}
