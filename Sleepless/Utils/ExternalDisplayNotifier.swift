import Foundation
import OSLog
import AppKit

extension NSNotification.Name {
    static let ExternalDisplay = Notification.Name("ExternalDisplay")
}

class ExternalDisplayNotifier {
    
    static var ready: Bool = false
    static var externalDisplay: Bool? = nil
    
    private init() {}
    
    static func setup() {
        if ready {
            fatalError("ExternalDisplayNotifier already initialized")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDisplayConnection),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        
        ready = true
    }
    
    @objc
    static func handleDisplayConnection(notification: Notification) {
        let externalDisplay = self.hasExternalDisplay()
        
        if externalDisplay != self.externalDisplay {
            self.externalDisplay = externalDisplay
            
            if externalDisplay {
                SleepManager.disable()
            } else {
                SleepManager.enable()
            }
        }
    }
    
    static func hasExternalDisplay() -> Bool {
        let description: NSDeviceDescriptionKey = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        
        return NSScreen.screens.contains {
            guard let deviceID = $0.deviceDescription[description] as? NSNumber else {
                return false
            }
            
            return CGDisplayIsBuiltin(deviceID.uint32Value) == 0
        }
    }
    
}
