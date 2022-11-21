import Cocoa

class LauncherAppDelegate: NSObject, NSApplicationDelegate {
    
    static let sleeplessBundleIdentifier = "fr.mbenoukaiss.Sleepless"
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let isRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == Self.sleeplessBundleIdentifier
        }
        
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            
            let applicationPathString = path as String
            guard let pathURL = URL (string: applicationPathString) else { return }
            NSWorkspace.shared.openApplication(
                at: pathURL,
                configuration: NSWorkspace.OpenConfiguration(),
                completionHandler: nil
            )
        }
    }
}

