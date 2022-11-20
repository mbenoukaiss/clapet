import SwiftUI
import ServiceManagement
import OSLog
import KeyboardShortcuts

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
        ScrollView {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                GridRow(alignment: .top) {
                    Text("")
                    VStack(alignment: .leading) {
                        Toggle(isOn: $launchAtLogin.onChange(self.onLaunchAtLoginChange)) {
                            Text("Launch at login")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        Toggle(isOn: $showMenuIcon) {
                            Text("Show menu bar icon")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Divider()
                GridRow(alignment: .top) {
                    Text("Shortcuts")
                    VStack(alignment: .leading) {
                        Text("Enable sleep")
                        KeyboardShortcuts.Recorder(for: .enableSleep)
                        Text("Global shortcut allowing the computer to go to sleep")
                            .asHint()
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Disable sleep").padding(.top, 5)
                        KeyboardShortcuts.Recorder(for: .disableSleep)
                        Text("Global shortcut forbiding the computer to go to sleep until sleep is activated either manually or automatically")
                            .asHint()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider()
                GridRow(alignment: .top) {
                    Text("Inactivity")
                    VStack(alignment: .leading) {
                        Toggle(isOn: $enableInactivityDelay) {
                            Text("Enable inactivity delay")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        NumberField("", value: $inactivityDelay.onChange {
                            inactivityService.setDelay(delay: $0)
                        })
                        .disabled(!enableInactivityDelay)
                        .frame(width: 100)
                        .padding(.top, 5)
                        
                        Text("After \(inactivityDelay) minutes of inactivity, sleep will be automatically enabled again to preserve battery")
                            .asHint()
                    }
                }
            }
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
