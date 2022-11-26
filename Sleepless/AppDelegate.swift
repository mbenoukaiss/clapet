import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    func applicationDidFinishLaunching(_: Notification) {
        let alreadySetup = UserDefaults.standard.bool(forKey: StorageKeys.alreadySetup)
        if alreadySetup {
            NSApp.setActivationPolicy(.prohibited)
        }
    }
    
}
