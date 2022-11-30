import Foundation

extension Date: RawRepresentable {
    
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
    
}

extension Date?: RawRepresentable {
    
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        if let date = self {
            return Date?.formatter.string(from: date)
        } else {
            return ""
        }
    }
    
    public init?(rawValue: String) {
        if rawValue == "" {
            self = nil
        } else {
            self = Date?.formatter.date(from: rawValue)
        }
    }
    
}
