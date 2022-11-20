import SwiftUI
import KeyboardShortcuts

@main
struct SleeplessApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate: AppDelegate
    
    @AppStorage(StorageKeys.sleepDurations)
    private var durations: [SleepDuration] = StorageKeys.initial(StorageKeys.sleepDurations)
    
    let inactivityService: InactivityService
    let sleepService: SleepService
    
    init() {
        self.inactivityService = InactivityService()
        self.sleepService = SleepService(inactivityService: inactivityService)
        
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
            let delay = duration.time
            KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name(duration.id.uuidString)) {
                self.sleepService.disableFor(delay)
            }
        }
    }
    
    func onQuit(notification: Notification) {
        //reenable sleep when the app quit to avoid
        //accidentally leaving the computer in a state
        //where sleep is disabled
        
        sleepService.enableSynchronous()
    }
}
