import SwiftUI
import OSLog
import UserNotifications

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
    
    var pendingEnabler: DispatchWorkItem? = nil
    var notificationId: String? = nil
    var inactivityTimer: Timer? = nil
    
    init(inactivityService: InactivityService, notificationService: NotificationService) {
        self.inactivityService = inactivityService
        self.notificationService = notificationService
        
        //trigger automatic change after its value has been
        //loaded from app storage
        self.toggleAutomaticMode(automatic: automatic)
    }
    
    func isAutomaticSuspended() -> Bool {
        pendingEnabler != nil
    }
    
    func toggleAutomaticMode(automatic: Bool) {
        if automatic {
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
        
        if synchronous {
            runSynchronous("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
        } else {
            run("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
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
        
        run("sudo pmset -b sleep 0; sudo pmset -b disablesleep 1");
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
    
    func run(_ command: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runSynchronous(command)
        }
    }
    
    func runSynchronous(_ command: String) {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: "do shell script \"\(command)\"")!
        
        logger.info("Running command \(command)")
        scriptObject.executeAndReturnError(&error)
        
        if let error = error {
            logger.error("Failed to run command with error : \(error.description)")
        }
    }
    
}
