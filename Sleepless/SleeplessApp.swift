import SwiftUI
import Combine

@main
struct SleeplessApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate: AppDelegate
    
    let inactivityService: InactivityService
    let sleepService: SleepService
    
    init() {
        self.inactivityService = InactivityService()
        self.sleepService = SleepService(inactivityService: inactivityService)
        
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
    
    func onQuit(notification: Notification) {
        //reenable sleep when the app quit to avoid
        //accidentally leaving the computer in a state
        //where sleep is disabled
        
        sleepService.enable()
    }
}
