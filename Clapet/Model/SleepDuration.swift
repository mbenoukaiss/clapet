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
            return SleepDuration.display(time: time)
        }
        
        return "unknown-duration".localize()
    }
    
    static func display(time: Int) -> String {
        if time < 60 {
            return time == 1 ? "for-1-minute".localize() : "for-x-minutes".localize(time)
        } else if time % 60 == 0 {
            return time == 60 ? "for-1-hour".localize() : "for-x-hours".localize(time / 60)
        } else {
            let hours = time / 60
            let minutes = time % 60
            if hours == 1 && minutes == 1 {
                return "for-hour-minute".localize()
            } else if hours == 1 && minutes != 1 {
                return "for-hour-minutes".localize(minutes)
            } else if hours != 1 && minutes == 1 {
                return "for-hours-minute".localize(hours)
            } else {
                return "for-hours-minutes".localize(hours, minutes)
            }
        }
    }
    
}

extension Binding where Value == SleepDuration {
    func display() -> Binding<String?> {
        return self.transform {
            $0.display()
        }
    }
}
