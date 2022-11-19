import SwiftUI
import ServiceManagement
import OSLog

struct GeneralSettings: View {

    private let logger = Logger()
    
    @EnvironmentObject
    private var inactivityService: InactivityService
    
    @AppStorage(StorageKeys.launchAtLogin)
    private var launchAtLogin: Bool = StorageKeys.initial(StorageKeys.launchAtLogin)
    
    @AppStorage(StorageKeys.showMenuIcon)
    private var showMenuIcon: Bool = StorageKeys.initial(StorageKeys.showMenuIcon)
    
    @AppStorage(StorageKeys.enableInactivityDelay)
    private var enableInactivityDelay: Bool = StorageKeys.initial(StorageKeys.enableInactivityDelay)
    
    @AppStorage(StorageKeys.inactivityDelay)
    private var inactivityDelay: Int = StorageKeys.initial(StorageKeys.inactivityDelay)
    
    var body: some View {
        Form {
            Toggle(isOn: $launchAtLogin.onChange(self.onLaunchAtLoginChange)) {
                Text("Launch at login")
            }
            Toggle(isOn: $showMenuIcon) {
                Text("Show menu bar icon")
            }
            
            Toggle(isOn: $enableInactivityDelay) {
                Text("Enable inactivity delay")
            }
            
            NumberField("", value: $inactivityDelay.onChange {
                inactivityService.setDelay(delay: $0)
            })
            .disabled(!enableInactivityDelay)
            .frame(width: 100)
            
            Text("After \(inactivityDelay) minutes of inactivity, sleep will be automatically enabled again to preserve battery")
                .hint()
        }.padding(10)
    }
    
    func onLaunchAtLoginChange(launch: Bool) {
        do {
            if launch {
                if SMAppService.mainApp.status == .enabled {
                    try? SMAppService.mainApp.unregister()
                }
                
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            logger.error("Failed to \(launch ? "enable" : "disable") launch at login: \(error.localizedDescription)")
        }
    }
}
