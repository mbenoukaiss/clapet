import SwiftUI
import ServiceManagement
import OSLog

struct GeneralSettings: View {
    
    private let logger = Logger()
    
    @EnvironmentObject
    private var inactivityService: InactivityService
    
    @State
    private var launchOnStartup: Bool
    
    @AppStorage(StorageKeys.showMenuIcon)
    private var showMenuIcon: Bool = StorageDefaults.showMenuIcon
    
    @AppStorage(StorageKeys.showDockIcon)
    private var showDockIcon: Bool = StorageDefaults.showDockIcon
    
    @AppStorage(StorageKeys.checkForUpdates)
    private var checkForUpdates: Bool = StorageDefaults.checkForUpdates
    
    @AppStorage(StorageKeys.enableInactivityDelay)
    private var enableInactivityDelay: Bool = StorageDefaults.enableInactivityDelay
    
    @AppStorage(StorageKeys.inactivityDelay)
    private var inactivityDelay: Int = StorageDefaults.inactivityDelay
    
    @AppStorage(StorageKeys.closedLidForceSleep)
    private var closedLidForceSleep: Bool = StorageDefaults.closedLidForceSleep
    
    init() {
        _launchOnStartup = State(initialValue: SMAppService.mainApp.status == .enabled)
    }
    
    var body: some View {
        ScrollView {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                GridRow(alignment: .top) {
                    Text("behavior")
                    VStack(alignment: .leading) {
                        Toggle(isOn: $launchOnStartup.onChange(onLaunchOnStartupChange)) {
                            Text("launch-at-login")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        #if DEBUG
                        .disabled(true)
                        .help("Disabled in debug mode")
                        #endif
                        
                        Toggle(isOn: $showMenuIcon) {
                            Text("menu-bar-icon")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle(isOn: $showDockIcon) {
                            Text("dock-icon")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle(isOn: $checkForUpdates) {
                            Text("check-for-updates")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                 
                        Text("check-for-updates-description").asHint()
}
                }
                Divider()
                GridRow(alignment: .top) {
                    Text("inactivity")
                    VStack(alignment: .leading) {
                        Toggle(isOn: $enableInactivityDelay) {
                            Text("enable-inactivity-delay")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        NumberField("", value: $inactivityDelay.onChange {
                            inactivityService.setDelay(delay: $0)
                        })
                        .disabled(!enableInactivityDelay)
                        .frame(width: 100)
                        .padding(.top, 5)
                        
                        Text("inactivity-delay-description".localize(inactivityDelay)).asHint()
                        
                        Toggle("closed-lid-force-sleep", isOn: $closedLidForceSleep)
                        Text("closed-lid-force-sleep-description")
                            .asHint()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .frame(width: 410, height: 250)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
    func onLaunchOnStartupChange(launch: Bool) {
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
            launchOnStartup = false
        }
    }
    
}
