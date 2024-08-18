import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    
    static var isVisible: Bool = true;
    
    let updateService: UpdateService
    let notificationService: NotificationService
    let inactivityService: InactivityService
    let sleepService: SleepService
    
    @AppStorage(StorageKeys.alreadySetup)
    private var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    @AppStorage(StorageKeys.showDockIcon)
    private var showDockIcon: Bool = StorageDefaults.showDockIcon
    
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
            if !self.showDockIcon {
                AppDelegate.hideApplication()
            }
            
            updateService.checkForUpdate()
        }
    }
    
    static func isApplicationVisible() -> Bool {
        return Self.isVisible;
    }
    
    static func showApplication(bringToFront: Bool = false) {
        Self.isVisible = true;
        NSApp.setActivationPolicy(.regular)
        
        if bringToFront {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.filter({ $0.isVisible }).last?.orderFrontRegardless()
        }
    }
    
    static func hideApplication() {
        Self.isVisible = false;
        NSApp.setActivationPolicy(.prohibited);
    }
}
