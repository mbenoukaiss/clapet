import Foundation
import OSLog
import AppKit
import SwiftUI

class InactivityService: ObservableObject {
    
    static let defaultDelay: Int = 15
    
    let logger = Logger()
    
    @AppStorage(StorageKeys.inactivityDelay)
    private var delay: Int = StorageDefaults.inactivityDelay
    
    func setDelay(delay: Int) {
        if delay == 0 {
            return
        }
        
        self.delay = delay
    }
    
    @discardableResult
    func onInactive(_ then: @escaping () -> Void) -> Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            let delay = Double(self.delay) * 60.0
            let lastEvent = CGEventSource.secondsSinceLastEventType(
                CGEventSourceStateID.hidSystemState,
                eventType: CGEventType(rawValue: ~0)!
            )
            
            if lastEvent > delay {
                self.logger.info("Computer has been inactive for \(delay), triggering onInactive callback")
                then()
                
                $0.invalidate()
            }
        }
    }
    
}
