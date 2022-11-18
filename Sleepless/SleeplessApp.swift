import SwiftUI
import Combine

@main
struct SleeplessApp: App {
    
    private var sinks : Set<AnyCancellable> = Set()
    
    init() {
        //detects inactivity
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            var lastEvent:CFTimeInterval = 0
            lastEvent = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
            print(lastEvent)
        }
    }
    
    var body: some Scene {
        MenuBarExtra("Sleep manager", systemImage: "sleep") {
            Button("Disable sleep") {
                SleepManager.disable()
            }.keyboardShortcut("d")
            
            Button("Enable sleep") {
                SleepManager.enable()
            }.keyboardShortcut("s")
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}
