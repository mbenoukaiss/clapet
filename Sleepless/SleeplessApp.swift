import SwiftUI
import KeyboardShortcuts
import UserNotifications
import OSLog

@main
struct SleeplessApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate: AppDelegate
    
    @AppStorage(StorageKeys.alreadySetup)
    private var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    @AppStorage(StorageKeys.sleepDurations)
    private var durations: [SleepDuration] = StorageDefaults.sleepDurations
    
    let notificationService: NotificationService
    let inactivityService: InactivityService
    let sleepService: SleepService
    
    init() {
        self.notificationService = NotificationService()
        self.inactivityService = InactivityService()
        self.sleepService = SleepService(
            inactivityService: inactivityService,
            notificationService: notificationService
        )
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            let logger = Logger()
            
            if success {
                logger.info("Permission to send notifications has been granted")
            } else if let error = error {
                logger.error("\(error.localizedDescription)")
            }
        }
        
        self.setupShortcuts();
        
        //register application quit listener
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main,
            using: self.onQuit
        )
    }
    
    var body: some Scene {
        MenuBar(
            inactivityService: inactivityService,
            sleepService: sleepService
        )
        
        WindowGroup {
            if !alreadySetup {
                Introduction()
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(inactivityService)
                .environmentObject(sleepService)
        }
    }
    
    func setupShortcuts() {
        KeyboardShortcuts.removeAllHandlers();
        
        KeyboardShortcuts.onKeyUp(for: .enableSleep) {
            self.sleepService.enable()
        }
        
        KeyboardShortcuts.onKeyUp(for: .disableSleep) {
            self.sleepService.disable()
        }
        
        for duration in durations {
            //TODO: test this when value changes
            let delay = duration.time
            KeyboardShortcuts.onKeyUp(for: .init(duration.id.uuidString)) {
                if let delay = delay {
                    self.sleepService.disableFor(delay)
                }
            }
        }
    }
    
    func onQuit(notification: Notification) {
        //reenable sleep when the app quit to avoid
        //accidentally leaving the computer in a state
        //where sleep is disabled
        
        sleepService.enable(synchronous: true)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
