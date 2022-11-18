import SwiftUI
import Combine

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

@main
struct SleeplessApp: App {
    
    private var sinks : Set<AnyCancellable> = Set()
    
    @AppStorage("automatic")
    private var automatic: Bool = false
    
    @State
    private var sleepless: Bool? = nil
    
    init() {
        //register application quit listener
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main,
            using: self.onQuit
        )
        
        //enable sleep after 15 minutes of inactivity
        //so the battery doesn't die out
        InactivityNotifier.after(15) {
            SleepManager.enable()
        }
        
        //trigger automatic change after its value has been
        //loaded from app storage
        onAutomaticChange(automatic: automatic)
    }
    
    var body: some Scene {
        MenuBarExtra("Sleep manager", systemImage: "sleep") {
            Text("Sleep currently \(self.sleepless ?? false ? "disabled" : "enabled")")
                .foregroundColor(.white)
            Toggle(isOn: $automatic.onChange(self.onAutomaticChange)) {
                Text("Automatically handle sleep")
            }
            
            Divider()
            
            Button("Disable sleep") {
                self.toggleSleepless(true)
            }.keyboardShortcut("d").disabled(automatic)
            
            Button("Enable sleep") {
                self.toggleSleepless(false)
            }.keyboardShortcut("e").disabled(automatic)
            
            Divider()
            
            Button("Preferences") {
                print("open preferences")
            }.keyboardShortcut("s")
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
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
    
    func onQuit(notification: Notification) {
        //reenable sleep when the app quit to avoid
        //accidentally leaving the computer in a state
        //where sleep is disabled
        
        SleepManager.enable()
    }
}
