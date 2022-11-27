import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        TabView {
            GeneralSettings().tabItem {
                Label("general", systemImage: "gear")
            }
            
            TimesSettings().tabItem {
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
    }
    
}
