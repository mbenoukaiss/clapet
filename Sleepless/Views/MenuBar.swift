import SwiftUI

struct MenuBar: Scene {
    
    private var inactivityService: InactivityService
    
    @ObservedObject
    private var sleepService: SleepService
    
    @AppStorage(StorageKeys.automatic)
    private var automatic: Bool = StorageKeys.initial(StorageKeys.automatic)
    
    @AppStorage(StorageKeys.showMenuIcon)
    private var showMenuIcon: Bool = StorageKeys.initial(StorageKeys.showMenuIcon)
    
    @AppStorage(StorageKeys.sleepDurations)
    private var sleepDurations: [SleepDuration] = StorageKeys.initial(StorageKeys.sleepDurations)
    
    @State
    private var settingsOpen: Bool = false
    
    init(inactivityService: InactivityService, sleepService: SleepService) {
        self.inactivityService = inactivityService
        self.sleepService = sleepService
        
        //trigger automatic change after its value has been
        //loaded from app storage
        onAutomaticChange(automatic: automatic)
    }
    
    var body: some Scene {
        let sortedDurations = sleepDurations.sorted(by: { $0.time < $1.time })
        
        MenuBarExtra("Sleep manager", systemImage: "sleep", isInserted: $showMenuIcon) {
            VStack {
                Toggle(isOn: $automatic.onChange(self.onAutomaticChange)) {
                    Text("Automatically handle sleep")
                }
                
                //TODO: say for how long if temporary
                Text("Sleep currently \(sleepService.enabled ? "enabled" : "disabled")")
                
                Divider()
                
                Menu("Disable sleep") {
                    ForEach(sortedDurations) { duration in
                        Button("For \(duration.time) minutes") {
                            self.toggleSleepless(true, delay: duration.time)
                        }
                    }
                    
                    Button("Until enabled") {
                        self.toggleSleepless(true)
                    }
                }
                
                Button("Enable sleep") {
                    self.toggleSleepless(false)
                }.keyboardShortcut("e").disabled(automatic || sleepService.enabled)
                
                Divider()
                
                Button("Preferences") {
                    openSettings()
                }.keyboardShortcut("s")
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q")
            }
            .environmentObject(inactivityService)
            .environmentObject(sleepService)
        }
    }
    
    private func openSettings() {
        if settingsOpen {
            return
        }
        
        settingsOpen = true
        
        //add application to alt tab
        NSApp.setActivationPolicy(.regular)
        
        //bring application to front
        NSApp.activate(ignoringOtherApps: true)
        
        //open settings
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        
        //remove from alt tab when settings window when hidden
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            if let settings = NSApp.windows.last {
                if !settings.isVisible {
                    settingsOpen = false
                    NSApp.setActivationPolicy(.accessory)
                    
                    $0.invalidate()
                }
            }
        }
    }
    
    func onAutomaticChange(automatic: Bool) {
        if automatic {
            if !sleepService.isAutomaticOverriden() {
                //toggle sleep based on current state
                self.toggleSleepless(ExternalDisplayNotifier.hasExternalDisplay())
            }
            
            //register listener for future changes
            ExternalDisplayNotifier.listen {
                if !sleepService.isAutomaticOverriden() {
                    self.toggleSleepless($0)
                }
            }
        } else {
            ExternalDisplayNotifier.stop()
        }
    }
    
    func toggleSleepless(_ sleepless: Bool, delay: Int? = nil) {
        if let delay = delay {
            if sleepless {
                sleepService.disableFor(delay)
            } else {
                fatalError("Invalid state : can not enable sleep with `for` parameter")
            }
        } else {
            if sleepless {
                sleepService.disable()
            } else {
                sleepService.enable()
            }
        }
    }
    
}
