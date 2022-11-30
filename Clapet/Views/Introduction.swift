import SwiftUI
import UserNotifications
import ServiceManagement
import OSLog

struct Introduction: View {
    
    private let logger = Logger()
    
    @EnvironmentObject
    private var sleepService: SleepService
    
    @AppStorage(StorageKeys.automatic)
    var automatic: Bool = StorageDefaults.automatic
    
    @AppStorage(StorageKeys.alreadySetup)
    private var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    @State
    private var launchOnStartup: Bool
    
    @State
    private var showExplanationPopover: Bool
    
    @State
    private var showSkipPopover: Bool
    
    init() {
        _launchOnStartup = State(initialValue: true)
        _showExplanationPopover = State(initialValue: false)
        _showSkipPopover = State(initialValue: false)
        
        askForNotifications()
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: {}) {
                Label("general", systemImage: "questionmark").labelStyle(.iconOnly)
            }
            .clipShape(Circle())
            .onHover { showExplanationPopover = $0 }
            .popover(isPresented: $showExplanationPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                Text("detailed-pmset-explanation")
                    .padding(.all, 10)
                    .frame(width: 300)
            }
        }
        .padding(.trailing, 10)
        .padding(.top, -15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        
        VStack(alignment: .center) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding(.bottom, 5)
            
            Text("clapet-description")
                .fontWeight(.semibold)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(LocalizedStringKey((sleepService.pmsetAccessible == false ? "clapet-pmset-description" : "clapet-no-pmset-description").localize().replacingOccurrences(of: "\n", with: "")))
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Toggle("introduction-launch-startup", isOn: $launchOnStartup)
            
            if sleepService.pmsetAccessible == false {
                HStack {
                    Button("click-skip", action: { skipConfiguration(alreadyConfigured: false) })
                        .onHover { showSkipPopover = $0 }
                        .popover(isPresented: $showSkipPopover) {
                            Text("configure-later")
                                .padding(.all, 10)
                                .frame(width: 250)
                        }
                    
                    Button("click-pmset-proceed", action: { configurePmset() })
                        .keyboardShortcut(.defaultAction)
                }
            } else {
                Button("click-proceed", action: { skipConfiguration(alreadyConfigured: true) })
                    .disabled(sleepService.pmsetAccessible == nil)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .frame(width: 550, height: 390)
        .padding(.top, -25)
        .padding(.bottom, 35)
        .padding(.horizontal, 100)
    }
    
    func configurePmset() {
        Shell.run("echo '\(NSUserName()) ALL = NOPASSWD : /usr/bin/pmset' | EDITOR='tee -a' visudo", admin: true) { _ in
            sleepService.pmsetAccessible = true
            alreadySetup = true
            automatic = true
            
            finalizeSetup()
        }
    }
    
    func skipConfiguration(alreadyConfigured: Bool) {
        alreadySetup = true
        automatic = alreadyConfigured
        
        finalizeSetup()
    }
    
    func finalizeSetup() {
        AppDelegate.hideApplication()
        
        if launchOnStartup {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try? SMAppService.mainApp.unregister()
                }
                
                try SMAppService.mainApp.register()
            } catch {
                logger.error("Failed to enable launch at login: \(error.localizedDescription)")
            }
        }
        
        sleepService.toggleAutomaticMode()
    }
    
    func askForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            let logger = Logger()
            
            if success {
                logger.info("Permission to send notifications has been granted")
            } else if let error = error {
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
}
