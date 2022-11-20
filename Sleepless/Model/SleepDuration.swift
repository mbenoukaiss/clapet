import SwiftUI
import KeyboardShortcuts

struct SleepDuration: Identifiable, Codable {
    
    let id: UUID
    var label: String?
    var time: Int?
    var notify: Bool
    
    func display() -> String {
        if let label = self.label {
            return label
        } else if let time = self.time {
            if time < 60 {
                return "For \(time) minute\(time != 1 ? "s" : "")"
            } else if time % 60 == 0 {
                return "For \(time / 60) hour\(time / 60 != 1 ? "s" : "")"
            } else {
                return "For \(time / 60) hour\(time / 60 != 1 ? "s" : "") \(time % 60) minute\(time % 60 != 1 ? "s" : "")"
            }
        }
        
        return "Unknown"
    }
    
}
