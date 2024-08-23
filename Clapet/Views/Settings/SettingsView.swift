import SwiftUI

struct SettingsView: View {
    
    @AppStorage(StorageKeys.showDockIcon)
    private var showDockIcon: Bool = StorageDefaults.showDockIcon

    var body: some View {
        TabView {
            GeneralSettings().tabItem {
                Label("general", systemImage: "gear")
            }
            
            DurationSettings().tabItem {
                Label("deactivation-durations", systemImage: "timer")
            }
            
            ShortcutSettings().tabItem {
                Label("shortcuts", systemImage: "keyboard")
            }
            
            NotificationSettings().tabItem {
                Label("notifications", systemImage: "bell")
            }
            
            AdvancedSettings().tabItem {
                Label("advanced", systemImage: "ellipsis.curlybraces")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { a in
            if let window = a.object {
                if (window as! NSWindow).isVisible && !self.showDockIcon {
                    AppDelegate.hideApplication()
                }
            }
        }
    }
    
}
