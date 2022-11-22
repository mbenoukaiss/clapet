import SwiftUI
import ServiceManagement
import OSLog

struct AdvancedSettings: View {
    
    private let logger = Logger()
    
    @EnvironmentObject
    private var sleepService: SleepService
    
    @AppStorage(StorageKeys.automaticReactivationDelay)
    private var automaticReactivationDelay: Int = StorageDefaults.automaticReactivationDelay
    
    @AppStorage(StorageKeys.closedLidForceSleep)
    private var closedLidForceSleep: Bool = StorageDefaults.closedLidForceSleep
    
    var body: some View {
        ScrollView {
            Form {
                NumberField("delay-automatic-reactivation", value: $automaticReactivationDelay)
                    .frame(width: 200)
                    .padding(.top, 2)
                
                Text("delay-automatic-reactivation-description")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("closed-lid-force-sleep", isOn: $closedLidForceSleep)
                Text("closed-lid-force-sleep-description")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .padding(.bottom, 10)
                
                Button("configure-pmset", action: configurePmset)
                    .disabled(sleepService.pmsetAccessible ?? true)
                Text(sleepService.pmsetAccessible == true ? "pmset-already-configured" : "pmset-configure-tooltip")
                    .asHint()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 410, height: 250)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
    func configurePmset() {
        Shell.run("echo '\(NSUserName()) ALL = NOPASSWD : /usr/bin/pmset' | EDITOR='tee -a' visudo", admin: true) { _ in
            sleepService.pmsetAccessible = true
        }
    }
    
}
