import SwiftUI

struct MenuBar: Scene {
    
    private var inactivityService: InactivityService
    
    @ObservedObject
    private var sleepService: SleepService
    
    @AppStorage(StorageKeys.showMenuIcon)
    private var showMenuIcon: Bool = StorageDefaults.showMenuIcon
    
    @AppStorage(StorageKeys.sleepDurations)
    private var sleepDurations: [SleepDuration] = StorageDefaults.sleepDurations
    
    @State
    private var settingsOpen: Bool = false
    
    private var timeFormatter: DateFormatter
    
    init(inactivityService: InactivityService, sleepService: SleepService) {
        self.inactivityService = inactivityService
        self.sleepService = sleepService
        
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = "HH:mm"
    }
    
    var body: some Scene {
        let sortedDurations = sleepDurations
            .filter { $0.time != nil }
            .sorted(by: { $0.time.unsafelyUnwrapped < $1.time.unsafelyUnwrapped })
        
        MenuBarExtra("Sleep manager", systemImage: sleepService.enabled ? "moon.stars" : "moon.stars.fill", isInserted: $showMenuIcon) {
            VStack {
                Toggle(isOn: $sleepService.automatic.onChange(sleepService.toggleAutomaticMode)) {
                    Text("Automatically handle sleep")
                }
                
                if let until = sleepService.disabledUntil {
                    Text("Sleep disabled until \(timeFormatter.string(from: until))")
                } else {
                    Text("Sleep currently \(sleepService.enabled ? "enabled" : "disabled")")
                }
                
                Divider()
                
                Menu("Disable sleep") {
                    ForEach(sortedDurations) { duration in
                        Button(duration.display()) {
                            self.toggleSleepless(true, delay: duration.time)
                        }
                    }
                    
                    Button("Until enabled") {
                        self.toggleSleepless(true)
                    }
                }
                
                Button("Enable sleep") {
                    self.toggleSleepless(false)
                }.keyboardShortcut("e").disabled(sleepService.automatic || sleepService.enabled)
                
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
