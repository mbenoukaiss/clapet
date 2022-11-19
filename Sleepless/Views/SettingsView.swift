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
        }.frame(width: 300, height: 150)
    }
}
