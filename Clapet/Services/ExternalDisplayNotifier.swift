import Foundation
import OSLog
import AppKit

extension NSNotification.Name {
    
    static let ExternalDisplay = Notification.Name("ExternalDisplay")
    
}

class ExternalDisplayNotifier {
    
    static var externalDisplay: Bool = hasExternalDisplay()
    
    static var observer: (() -> Void)? = nil
    
    private init() {}
    
    static func listen(_ then: @escaping () -> Void) {
        observer = then
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDisplayConnection),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    static func stop() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    static func handleDisplayConnection(notification: Notification) {
        let externalDisplay = hasExternalDisplay()
        
        if externalDisplay != self.externalDisplay {
            self.externalDisplay = externalDisplay
            
            if let observer = observer {
                observer()
            }
        }
    }
    
    private static func hasExternalDisplay() -> Bool {
        let description: NSDeviceDescriptionKey = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        
        return NSScreen.screens.contains {
            guard let deviceID = $0.deviceDescription[description] as? NSNumber else {
                return false
            }
            
            return CGDisplayIsBuiltin(deviceID.uint32Value) == 0
        }
    }
    
}
