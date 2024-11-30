import SwiftUI
import OSLog
import UserNotifications

class SleepService: ObservableObject {
    
    let logger = Logger()
    
    private var inactivityService: InactivityService
    private var notificationService: NotificationService
    private var updateService: UpdateService
    
    @Published
    var enabled: Bool = true
    
    @Published
    var disabledUntil: Date? = nil
    
    @Published
    var pmsetAccessible: Bool? = nil
    
    @AppStorage(StorageKeys.automatic)
    var automatic: Bool = StorageDefaults.automatic
    
    @AppStorage(StorageKeys.alreadySetup)
    var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    @AppStorage(StorageKeys.automaticReactivationDelay)
    var automaticReactivationDelay: Int = StorageDefaults.automaticReactivationDelay
    
    @AppStorage(StorageKeys.closedLidForceSleep)
    private var closedLidForceSleep: Bool = StorageDefaults.closedLidForceSleep
    
    @AppStorage(StorageKeys.showDockIcon)
    private var showDockIcon: Bool = StorageDefaults.showDockIcon
    
    var pendingEnabler: DispatchWorkItem? = nil
    var notificationId: String? = nil
    var inactivityTimer: Timer? = nil
    
    init(inactivityService: InactivityService, notificationService: NotificationService, updateService: UpdateService) {
        self.inactivityService = inactivityService
        self.notificationService = notificationService
        self.updateService = updateService
    }
    
    func initialize() {
        Shell.run("sudo -n pmset -g") {
            self.pmsetAccessible = $0.success
            
            if !self.pmsetAccessible! && self.alreadySetup {
                AppDelegate.showApplication(bringToFront: true);
                
                let alert = NSAlert()
                alert.messageText = "no-permission-title".localize()
                alert.informativeText = "no-permission-content".localize()
                alert.addButton(withTitle: "no-permission-autoconfigure".localize())
                alert.addButton(withTitle: "no-permission-open".localize())
                alert.addButton(withTitle: "cancel".localize())
                alert.alertStyle = .warning
                
                let action = alert.runModal();
                if action == .alertFirstButtonReturn {
                    self.autoconfigure();
                } else if action == .alertSecondButtonReturn {
                    if let url = URL(string: "https://github.com/mbenoukaiss/clapet#manual-configuration") {
                        NSWorkspace.shared.open(url)
                    }
                    
                    if !self.showDockIcon {
                        AppDelegate.hideApplication()
                    }
                }
            }
            
            //trigger automatic change after its value has been
            //loaded from app storage
            if self.alreadySetup {
                //delay because notifications on app startup
                //don't get sent sometimes ?
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.toggleAutomaticMode()
                }
            }
        }
        
        //reenable sleep on wake if the correct conditions are met
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main,
            using: { _ in self.toggleByDisplays(delayEnabling: false) }
        )
    }
    
    func autoconfigure() {
        Shell.run("echo '\(NSUserName()) ALL = NOPASSWD : /usr/bin/pmset' | EDITOR='tee -a' visudo", admin: true) { _ in
            self.pmsetAccessible = true
        }
    }
    
    func isAutomaticSuspended() -> Bool {
        pendingEnabler != nil
    }
    
    func toggleAutomaticMode(automatic: Bool? = nil) {
        if automatic ?? self.automatic {
            logger.info("Enabling automatic sleep mode")
            
            toggleByDisplays(delayEnabling: false)
            
            //register listener for future changes
            ExternalDisplayNotifier.listen {
                self.toggleByDisplays(delayEnabling: true)
            }
        } else {
            logger.info("Disabling automatic sleep mode")
            
            ExternalDisplayNotifier.stop()
        }
    }
    
    private func toggleByDisplays(delayEnabling: Bool) {
        if automatic && !isAutomaticSuspended() {
            if ExternalDisplayNotifier.externalDisplay {
                disable()
            } else if delayEnabling {
                logger.info("Delaying sleep enable by \(self.automaticReactivationDelay) after screen has been unplugged")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(automaticReactivationDelay)) {
                    if !ExternalDisplayNotifier.externalDisplay {
                        self.enable()
                    }
                }
            } else {
                enable()
            }
            
            notificationService.sendAutomaticChange(enabled: enabled)
        }
    }
    
    func enable(synchronous: Bool = false) {
        cancelDisableFor()
        
        logger.info("Enabling sleep")
        enabled = true
        
        if let pmsetAccessible = pmsetAccessible {
            if synchronous {
                Shell.runSynchronous("sudo pmset -b disablesleep 0", admin: !pmsetAccessible);
            } else {
                Shell.run("sudo pmset -b disablesleep 0", admin: !pmsetAccessible) { _ in
                    if self.closedLidForceSleep {
                        self.putToSleep();
                    }
                }
            }
        } else {
            logger.error("Failed to run command because `pmsetAccessible` is not set")
        }
    }
    
    func disable(withTimer: Bool = true) {
        logger.info("Disabling sleep")
        enabled = false
        
        updateService.periodicalUpdateCheck()
        
        if let inactivityTimer = self.inactivityTimer {
            inactivityTimer.invalidate()
        }
        
        if withTimer {
            //enable sleep after delay of inactivity so the
            //battery doesn't get emptied if the user forgot
            //to turn sleep back on (default delay: 15m)
            self.inactivityTimer = inactivityService.onInactive {
                self.enable()
            }
        }
        
        if let pmsetAccessible = pmsetAccessible {
            Shell.run("sudo pmset -b disablesleep 1", admin: !pmsetAccessible);
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
            if !(self.automatic && ExternalDisplayNotifier.externalDisplay) {
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
        if pendingEnabler != nil {
            logger.info("Cancelling scheduled sleep enabling")
            
            pendingEnabler!.cancel()
            
            if let notification = self.notificationId {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification])
            }
            
            notificationId = nil
            disabledUntil = nil
            pendingEnabler = nil
        }
    }
    
    func forceSleep() {
        enable()
        
        logger.info("Putting the computer to sleep")
        Shell.run("pmset sleepnow")
    }
    
    func putToSleep() {
        Shell.run("ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState | head -1 | grep Yes || true") {
            let isLidClosed = $0.output.count != 0
            if isLidClosed {
                self.logger.info("Lid is closed: putting computer to sleep")
        
                Shell.run("pmset sleepnow")
            } else {
                self.logger.info("Lid is open: skipping sleep")
            }
        }
    }
    
}
