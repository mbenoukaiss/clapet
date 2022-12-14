import SwiftUI
import ServiceManagement
import OSLog
import KeyboardShortcuts

struct ShortcutSettings: View {
    
    private let logger = Logger()
    
    @AppStorage(StorageKeys.sleepDurations)
    private var times: [SleepDuration] = StorageDefaults.sleepDurations
    
    var body: some View {
        ScrollView {
            Form {
                KeyboardShortcuts.Recorder("enable-sleep-shortcut".localize(), name: .enableSleep)
                Text("enable-shortcut-description")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                KeyboardShortcuts.Recorder("disable-sleep-shortcut".localize(), name: .disableSleep)
                Text("disable-shortcut-description")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                KeyboardShortcuts.Recorder("sleep-now-shortcut".localize(), name: .sleepNow)
                Text("sleep-now-shortcut-description")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(times) { item in
                    KeyboardShortcuts.Recorder(item.display(), name: .init(item.id.uuidString))
                }
            }
        }
        .frame(width: 410, height: 300)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
}
