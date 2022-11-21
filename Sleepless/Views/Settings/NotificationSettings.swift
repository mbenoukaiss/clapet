import SwiftUI
import OSLog

struct NotificationSettings: View {
    
    private let logger = Logger()
    private let width: CGFloat = 390.0
    
    @AppStorage(StorageKeys.automaticSwitchNotification)
    private var automaticSwitchNotification: Bool = StorageDefaults.automaticSwitchNotification
    
    @AppStorage(StorageKeys.sleepDurations)
    private var sleepDurations: [SleepDuration] = StorageDefaults.sleepDurations
    
    var body: some View {
        ScrollView {
            Form {
                Toggle(isOn: $automaticSwitchNotification) {
                    Text("automatic-notifications")
                        .multilineTextAlignment(.trailing)
                        .frame(width: width / 2, alignment: .trailing)
                }
                .toggleStyle(.switch)
                .padding(.trailing, 60)
                
                ForEach($sleepDurations) { $duration in
                    Toggle(isOn: $duration.notify) {
                        Text(duration.display()).frame(width: width / 2, alignment: .trailing)
                    }
                    .toggleStyle(.switch)
                    .padding(.trailing, 60)
                }
            }.frame(width: width)
        }
        .frame(width: width, height: 250)
        .padding(10)
    }
    
}
