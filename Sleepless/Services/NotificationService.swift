import SwiftUI
import UserNotifications
import OSLog

class NotificationService: ObservableObject {
    
    let logger = Logger()
    
    @AppStorage(StorageKeys.automaticSwitchNotification)
    private var automaticSwitchNotification: Bool = StorageDefaults.automaticSwitchNotification
    
    @AppStorage(StorageKeys.sleepDurations)
    private var sleepDurations: [SleepDuration] = StorageDefaults.sleepDurations
    
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
    func sendAutomaticChange(enabled: Bool) -> String? {
        if automaticSwitchNotification {
            return send(
                title: "sleep-mode-change".localize(),
                text: enabled ? "automatically-enabled-sleep".localize() : "automatically-disabled-sleep".localize()
            )
        }
        
        return nil
    }
    
    @discardableResult
    func scheduleDisableFor(_ delay: Int, automatic: Bool) -> String? {
        let duration = sleepDurations.filter {
            $0.time == delay && $0.notify
        }.first
        
        if duration != nil {
            let showNotificationIn = calculateNotificationDelay(delay)
        
            logger.info("Scheduling notification to be sent in \(showNotificationIn) seconds")
            
            return send(
                title: "enable-sleep-soon".localize(),
                text: (automatic ? "sleep-enabled-in-automatic" : "sleep-enabled-in").localize(delay * 60 - showNotificationIn),
                delay: showNotificationIn
            )
        }
        
        return nil
    }
    
    func calculateNotificationDelay(_ delay: Int) -> Int {
        switch delay {
            case 1: return 45
            case 2...3: return 1 * 60 + 30
            default: return (delay - 1) * 60
        }
    }
    
}
