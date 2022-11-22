import SwiftUI
import ServiceManagement
import OSLog

struct GeneralSettings: View {
    
    private let logger = Logger()
    
    @EnvironmentObject
    private var inactivityService: InactivityService
    
    @AppStorage(StorageKeys.launchOnStartup)
    private var launchOnStartup: Bool = StorageDefaults.launchOnStartup
    
    @AppStorage(StorageKeys.showMenuIcon)
    private var showMenuIcon: Bool = StorageDefaults.showMenuIcon
    
    @AppStorage(StorageKeys.enableInactivityDelay)
    private var enableInactivityDelay: Bool = StorageDefaults.enableInactivityDelay
    
    @AppStorage(StorageKeys.inactivityDelay)
    private var inactivityDelay: Int = StorageDefaults.inactivityDelay
    
    var body: some View {
        ScrollView {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                GridRow(alignment: .top) {
                    Text("behavior")
                    VStack(alignment: .leading) {
                        Toggle(isOn: $launchOnStartup.onChange(onlaunchOnStartupChange)) {
                            Text("launch-at-login")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        #if DEBUG
                        .disabled(true)
                        .help("Disabled in debug mode")
                        #endif
                        
                        Toggle(isOn: $showMenuIcon) {
                            Text("menu-bar-icon")
                        }.frame(maxWidth: .infinity, alignment: .leading)
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
                    }
                }
            }
        }
        .frame(width: 410, height: 250)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
    func onlaunchOnStartupChange(launch: Bool) {
        #if !DEBUG
        SMLoginItemSetEnabled("fr.mbenoukaiss.SleeplessLauncher" as CFString, launch)
        #endif
//        do {
//            if launch {
//                if SMAppService.mainApp.status == .enabled {
//                    try? SMAppService.mainApp.unregister()
//                }
//
//                try SMAppService.mainApp.register()
//            } else {
//                try SMAppService.mainApp.unregister()
//            }
//        } catch {
//            logger.error("Failed to \(launch ? "enable" : "disable") launch at login: \(error.localizedDescription)")
//            launchOnStartup = !launch
//        }
    }
    
}
