import Foundation
import OSLog
import AppKit
import SwiftUI

class InactivityService: ObservableObject {
    
    static let defaultDelay: Int = 15
    
    @AppStorage(StorageKeys.inactivityDelay)
    private var delay: Int = StorageKeys.initial(StorageKeys.inactivityDelay)
    
    func setDelay(delay: Int) {
        if delay == 0 {
            return
        }
        
        self.delay = delay
    }
    
    @discardableResult
    func onInactive(_ then: @escaping () -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let delay = Double(self.delay) * 60.0
            let lastEvent = CGEventSource.secondsSinceLastEventType(
                CGEventSourceStateID.hidSystemState,
                eventType: CGEventType(rawValue: ~0)!
            )
            print(delay)
            if lastEvent > delay {
                then()
            }
        }
    }
    
}
