import SwiftUI
import OSLog
import UserNotifications

class SleepService: ObservableObject {
    
    let logger = Logger()
    
    private var inactivityService: InactivityService
    
    @Published
    var enabled: Bool = true
    
    @Published
    var disabledUntil: Date? = nil
    
    @AppStorage(StorageKeys.automatic)
    var automatic: Bool = StorageKeys.initial(StorageKeys.automatic)
    
    var pendingEnabler: DispatchWorkItem? = nil
    var notificationId: String? = nil
    var inactivityTimer: Timer? = nil
    
    init(inactivityService: InactivityService) {
        self.inactivityService = inactivityService
        
        //trigger automatic change after its value has been
        //loaded from app storage
        self.toggleAutomaticMode(automatic: automatic)
    }
    
    func isAutomaticSuspended() -> Bool {
        return self.pendingEnabler != nil
    }
    
    func toggleAutomaticMode(automatic: Bool) {
        if automatic {
            logger.info("Enabling automatic sleep mode")
            
            if !self.isAutomaticSuspended() {
                //toggle sleep based on current state
                if ExternalDisplayNotifier.hasExternalDisplay() {
                    self.disable()
                } else {
                    self.enable()
                }
            }
            
            //register listener for future changes
            ExternalDisplayNotifier.listen { isExternalDisplayConnected in
                if !self.isAutomaticSuspended() {
                    if isExternalDisplayConnected {
                        self.disable()
                    } else {
                        self.enable()
                    }
                }
            }
        } else {
            logger.info("Disabling automatic sleep mode")
            
            ExternalDisplayNotifier.stop()
        }
    }
    
    func enable(synchronous: Bool = false) {
        self.cancelDisableFor()
        
        logger.info("Enabling sleep")
        self.enabled = true
        
        if synchronous {
            self.runSynchronous("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
        } else {
            self.run("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
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
        
        self.run("sudo pmset -b sleep 0; sudo pmset -b disablesleep 1");
    }
    
    func disableFor(_ delay: Int) {
        //disable without inactivity timer because we
        //create our own timer regardless of activity
        self.disable(withTimer: false)
        
        self.cancelDisableFor()
        
        notificationId = self.scheduleNotification(delay)
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
        
        self.notificationId = nil
        self.disabledUntil = nil
        self.pendingEnabler = nil
    }
    
    func run(_ command: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runSynchronous(command)
        }
    }
    
    func runSynchronous(_ command: String) {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: "do shell script \"\(command)\"")!
        
        self.logger.info("Running command \(command)")
        scriptObject.executeAndReturnError(&error)
        
        if let error = error {
            self.logger.error("Failed to run command with error : \(error.description)")
        }
    }
    
    func scheduleNotification(_ delay: Int) -> String {
        let showNotificationIn = calculateNotificationDelay(delay)
        
        logger.info("Scheduling notification to be sent in \(showNotificationIn) seconds")
        
        let id = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "About to enable sleep"
        content.sound = UNNotificationSound.default
        
        if automatic {
            content.subtitle = "Sleep will be enabled in \(delay * 60 - showNotificationIn) seconds if no external display is plugged"
        } else {
            content.subtitle = "Sleep will be enabled in \(delay * 60 - showNotificationIn) seconds"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(showNotificationIn), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        return id
    }
    
    func calculateNotificationDelay(_ delay: Int) -> Int {
        switch delay {
            case 1: return 45
            case 2...3: return 1 * 60 + 30
            default: return (delay - 1) * 60
        }
    }
     
}
