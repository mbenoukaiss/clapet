import SwiftUI

struct MenuBar: Scene {
    
    private var inactivityService: InactivityService
    
    @AppStorage(StorageKeys.automatic)
    private var automatic: Bool = StorageKeys.initial(StorageKeys.automatic)
    
    @AppStorage(StorageKeys.showMenuIcon)
    private var showMenuIcon: Bool = StorageKeys.initial(StorageKeys.showMenuIcon)
    
    @State
    private var sleepless: Bool = false //todo: find the state
    
    @State
    private var settingsOpen: Bool = false
    
    init(inactivityService: InactivityService) {
        self.inactivityService = inactivityService
        
        //enable sleep after 15 minutes of inactivity
        //so the battery doesn't die out
        inactivityService.onInactive {
            SleepManager.enable()
        }
        
        //trigger automatic change after its value has been
        //loaded from app storage
        onAutomaticChange(automatic: automatic)
    }
    
    
    var body: some Scene {
        MenuBarExtra("Sleep manager", systemImage: "sleep", isInserted: $showMenuIcon) {
            VStack {
                Toggle(isOn: $automatic.onChange(self.onAutomaticChange)) {
                    Text("Automatically handle sleep")
                }
                
                Text("Sleep currently \(self.sleepless ? "disabled" : "enabled")")
                
                Divider()
                
                Button("Disable sleep") {
                    self.toggleSleepless(true)
                }.keyboardShortcut("d").disabled(automatic || self.sleepless)
                
                Button("Enable sleep") {
                    self.toggleSleepless(false)
                }.keyboardShortcut("e").disabled(automatic || !self.sleepless)
                
                Divider()
                
                Button("Preferences") {
                    openSettings()
                }.keyboardShortcut("s")
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q")
            }.environmentObject(inactivityService)
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
            //toggle sleep based on current state
            self.toggleSleepless(ExternalDisplayNotifier.hasExternalDisplay())
            
            //register listener for future changes
            ExternalDisplayNotifier.listen(self.toggleSleepless)
        } else {
            ExternalDisplayNotifier.stop()
        }
    }
    
    func toggleSleepless(_ sleepless: Bool) {
        if sleepless {
            SleepManager.disable()
        } else {
            SleepManager.enable()
        }
        
        self.sleepless = sleepless
    }
    
}
