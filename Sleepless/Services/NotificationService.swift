import Foundation
import UserNotifications
import OSLog

class NotificationService: ObservableObject {
    
    let logger = Logger()
    
    func send(title: String, text: String, delay: Int? = nil) -> String {
        let id = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = text
        content.sound = UNNotificationSound.default
        
        let trigger = delay != nil ? UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delay.unsafelyUnwrapped), repeats: false) : nil
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        return id
    }
    
    @discardableResult
    func sendAutomaticChange(enabled: Bool) -> String {
        return self.send(
            title: "Sleep mode change",
            text: enabled ? "Automatically enabled sleep" : "Automatically disabled sleep"
        )
    }
    
    @discardableResult
    func scheduleDisableFor(_ delay: Int, automatic: Bool) -> String {
        let showNotificationIn = calculateNotificationDelay(delay)
        
        logger.info("Scheduling notification to be sent in \(showNotificationIn) seconds")
        
        return self.send(
            title: "About to enable sleep",
            text: "Sleep will be enabled in \(delay * 60 - showNotificationIn) seconds\(automatic ? " if no external display is plugged" : "")",
            delay: showNotificationIn
        )
    }
    
    func calculateNotificationDelay(_ delay: Int) -> Int {
        switch delay {
            case 1: return 45
            case 2...3: return 1 * 60 + 30
            default: return (delay - 1) * 60
        }
    }
    
}
