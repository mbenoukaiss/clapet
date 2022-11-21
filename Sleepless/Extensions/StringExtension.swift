import Foundation

protocol Localizable: RawRepresentable where RawValue: StringProtocol {}

extension Localizable {
    var localize: String {
        print("CALCULATED")
        return NSLocalizedString(String(rawValue), comment: "")
    }
}

extension String {
    func localize(_ args: [CVarArg]) -> String {
        return String(
            format: NSLocalizedString(self, comment: ""),
            args
        )
    }
    
    func localize(_ args: CVarArg...) -> String {
        return String(
            format: NSLocalizedString(self, comment: ""),
            args
        )
    }
}
