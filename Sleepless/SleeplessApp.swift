import SwiftUI
import Combine

@main
struct SleeplessApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate: AppDelegate
    
    init() {
        //register application quit listener
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main,
            using: self.onQuit
        )
    }
    
    var body: some Scene {
        let inactivityService = InactivityService()
        
        MenuBar(inactivityService: inactivityService)
        
        Settings {
            SettingsView()
                .environmentObject(inactivityService)
        }
    }
    
    func onQuit(notification: Notification) {
        //reenable sleep when the app quit to avoid
        //accidentally leaving the computer in a state
        //where sleep is disabled
        
        SleepManager.enable()
    }
}
