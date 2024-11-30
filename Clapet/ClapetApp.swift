import SwiftUI
import KeyboardShortcuts
import UserNotifications

@main
struct ClapetApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var delegate: AppDelegate
    
    @AppStorage(StorageKeys.alreadySetup)
    private var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    @AppStorage(StorageKeys.sleepDurations)
    private var durations: [SleepDuration] = StorageDefaults.sleepDurations
    
    init() {
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
            inactivityService: delegate.inactivityService,
            sleepService: delegate.sleepService
        )
        
        WindowGroup("introduction") {
            if !alreadySetup {
                Introduction()
                    .environmentObject(delegate.inactivityService)
                    .environmentObject(delegate.sleepService)
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification), perform: { _ in
                        NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.closeButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    })
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
            CommandGroup(replacing: .saveItem, addition: { })
            CommandGroup(replacing: .help, addition: { })
            CommandGroup(replacing: .textEditing, addition: { })
            CommandGroup(replacing: .textFormatting, addition: { })
        }
        
        Settings {
            SettingsView()
                .environmentObject(delegate.inactivityService)
                .environmentObject(delegate.sleepService)
        }
    }
    
    func setupShortcuts() {
        KeyboardShortcuts.removeAllHandlers();
        
        KeyboardShortcuts.onKeyUp(for: .enableSleep) {
            delegate.sleepService.enable()
        }
        
        KeyboardShortcuts.onKeyUp(for: .disableSleep) {
            delegate.sleepService.disable()
        }
        
        KeyboardShortcuts.onKeyUp(for: .sleepNow) {
            delegate.sleepService.forceSleep()
        }
        
        for duration in durations {
            KeyboardShortcuts.onKeyUp(for: .init(duration.id.uuidString)) {
                //get the new duration object in case it has
                //changed since setup
                if let refreshed = durations.filter({ $0.id == duration.id && $0.time != nil }).first {
                    delegate.sleepService.disableFor(refreshed.time!)
                }
            }
        }
    }
    
    func onQuit(notification: Notification) {
        //reenable sleep when the app quit to avoid
        //accidentally leaving the computer in a state
        //where sleep is disabled
        delegate.sleepService.enable(synchronous: true)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
