import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        TabView {
            GeneralSettings().tabItem {
                Label("General", systemImage: "gear")
            }
            
            TimesSettings().tabItem {
                Label("Sleep times", systemImage: "timer")
            }
            
            ShortcutSettings().tabItem {
                Label("Shortcuts", systemImage: "keyboard")
            }
        }
    }
}
