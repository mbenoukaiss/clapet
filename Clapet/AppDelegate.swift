import AppKit
import SwiftUI
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    
    let logger = Logger()
    
    let updateService: UpdateService
    let notificationService: NotificationService
    let inactivityService: InactivityService
    let sleepService: SleepService
    
    @AppStorage(StorageKeys.alreadySetup)
    private var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    override init() {
        self.updateService = UpdateService()
        self.notificationService = NotificationService()
        self.inactivityService = InactivityService()
        self.sleepService = SleepService(
            inactivityService: inactivityService,
            notificationService: notificationService,
            updateService: updateService
        )
        
        super.init()
    }
    
    func applicationDidFinishLaunching(_: Notification) {
        sleepService.initialize()
        
        if alreadySetup {
            updateService.checkForUpdate()
        }
    }
    
    static func showApplication(bringToFront: Bool = false) {
        NSApp.setActivationPolicy(.regular)
        
        if bringToFront {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    static func hideApplication() {
        NSApp.setActivationPolicy(.prohibited)
    }
    
}
