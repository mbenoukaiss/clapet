import Foundation
import OSLog
import AppKit

extension NSNotification.Name {
    static let Inactivity = Notification.Name("Inactivity")
}

class InactivityNotifier {
    
    private init() {}
    
    @discardableResult
    static func after(_ delay: Int, then: @escaping () -> Void) -> Timer {
        let delay = Double(delay) * 60.0
        
        return Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            let lastEvent = CGEventSource.secondsSinceLastEventType(
                CGEventSourceStateID.hidSystemState,
                eventType: CGEventType(rawValue: ~0)!
            )
            
            if lastEvent > delay {
                then()
            }
        }
    }
    
}
