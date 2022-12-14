import Foundation

//required for arrays to be used in @AppStorage
extension Array: RawRepresentable where Element: Codable {
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        
        return result
    }
    
}

extension Array where Element: Identifiable {
    
    public mutating func move(_ element: Element, offset: Int) {
        if let index = self.firstIndex(where: { $0.id == element.id }) {
            let removed = self.remove(at: index)
            self.insert(removed, at: clamp(index + offset, 0, self.count))
        }
    }
    
}
