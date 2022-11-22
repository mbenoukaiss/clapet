import SwiftUI
import OSLog
import UserNotifications
import IOKit

class SleepService: ObservableObject {
    
    let logger = Logger()
    
    private var inactivityService: InactivityService
    private var notificationService: NotificationService
    
    @Published
    var enabled: Bool = true
    
    @Published
    var disabledUntil: Date? = nil
    
    @AppStorage(StorageKeys.automatic)
    var automatic: Bool = StorageDefaults.automatic
    
    @Published
    var pmsetAccessible: Bool? = nil
    
    @AppStorage(StorageKeys.alreadySetup)
    var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    var pendingEnabler: DispatchWorkItem? = nil
    var notificationId: String? = nil
    var inactivityTimer: Timer? = nil
    
    init(inactivityService: InactivityService, notificationService: NotificationService) {
        self.inactivityService = inactivityService
        self.notificationService = notificationService
        
        //trigger automatic change after its value has been
        //loaded from app storage
        if alreadySetup {
            self.toggleAutomaticMode()
        }
        
        Shell.run("sudo pmset -g") {
            self.pmsetAccessible = $0
        }
    }
    
    func isAutomaticSuspended() -> Bool {
        pendingEnabler != nil
    }
    
    func toggleAutomaticMode(automatic: Bool? = nil) {
        if automatic ?? self.automatic {
            logger.info("Enabling automatic sleep mode")
            
            if !isAutomaticSuspended() {
                //toggle sleep based on current state
                if ExternalDisplayNotifier.hasExternalDisplay() {
                    disable()
                } else {
                    enable()
                }
                
                notificationService.sendAutomaticChange(enabled: enabled)
            }
            
            //register listener for future changes
            ExternalDisplayNotifier.listen { isExternalDisplayConnected in
                if !self.isAutomaticSuspended() {
                    if isExternalDisplayConnected {
                        self.disable()
                    } else {
                        self.enable()
                    }
                    
                    self.notificationService.sendAutomaticChange(enabled: self.enabled)
                }
            }
        } else {
            logger.info("Disabling automatic sleep mode")
            
            ExternalDisplayNotifier.stop()
        }
    }
    
    func enable(synchronous: Bool = false) {
        cancelDisableFor()
        
        logger.info("Enabling sleep")
        enabled = true
        
        if let pmsetAccessible = pmsetAccessible {
            if synchronous {
                Shell.runSynchronous("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0", admin: !pmsetAccessible);
            } else {
                Shell.run("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0", admin: !pmsetAccessible);
            }
        } else {
            logger.error("Failed to run command because `pmsetAccessible` is not set")
        }
    }
    
    func disable(withTimer: Bool = true) {
        logger.info("Disabling sleep")
        enabled = false
        
        if let inactivityTimer = self.inactivityTimer {
            inactivityTimer.invalidate()
        }
        
        if withTimer {
            //enable sleep after delay of inactivity so the
            //battery doesn't get emptied if the user forgot
            //to turn off sleepless (default delay: 15m)
            self.inactivityTimer = inactivityService.onInactive {
                self.enable()
            }
        }
        
        if let pmsetAccessible = pmsetAccessible {
            Shell.run("sudo pmset -b sleep 0; sudo pmset -b disablesleep 1", admin: !pmsetAccessible);
        } else {
            logger.error("Failed to run command because `pmsetAccessible` is not set")
        }
    }
    
    func disableFor(_ delay: Int) {
        cancelDisableFor()
        
        //disable without inactivity timer because we
        //create our own timer regardless of activity
        disable(withTimer: false)
        
        notificationId = notificationService.scheduleDisableFor(delay, automatic: automatic)
        disabledUntil = Date().addingTimeInterval(TimeInterval(delay * 60))
        pendingEnabler = DispatchWorkItem(block: {
            self.pendingEnabler = nil
            
            //reenable only if it isn't in automatic mode with an external display
            //because automatic mode wouldn't have sleep enabled in this case
            if !(self.automatic && ExternalDisplayNotifier.hasExternalDisplay()) {
                self.enable()
            }
        })
        
        logger.info("Waiting \(delay) minutes to enable sleep again")
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Double(delay * 60),
            execute: pendingEnabler.unsafelyUnwrapped
        )
    }
    
    func cancelDisableFor() {
        logger.info("Cancelling scheduled sleep enabling")
        
        if let notification = self.notificationId {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification])
        }
        
        if let work = self.pendingEnabler {
            work.cancel()
        }
        
        notificationId = nil
        disabledUntil = nil
        pendingEnabler = nil
    }
    
}
