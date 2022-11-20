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
                KeyboardShortcuts.Recorder("Enable sleep", name: .enableSleep)
                Text("Global shortcut allowing the computer to go to sleep")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                KeyboardShortcuts.Recorder("Disable sleep", name: .disableSleep)
                Text("Global shortcut forbiding the computer to go to sleep until sleep is activated either manually or automatically")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(times) { item in
                    KeyboardShortcuts.Recorder(item.display(), name: .init(item.id.uuidString))
                }
            }
        }
        .frame(width: 390, height: 300)
        .padding(10)
    }
    
}
