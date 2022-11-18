import Foundation
import OSLog

class SleepManager {
    
    static let logger = Logger()
    
    static func disable() {
        logger.info("Disabling sleep")
        Self.run("sudo pmset -b sleep 0; sudo pmset -b disablesleep 1");
    }
    
    static func enable() {
        logger.info("Enabling sleep")
        Self.run("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
    }
    
    static func run(_ command: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            print("do shell script \"\(command)\"")
            let scriptObject = NSAppleScript(source: "do shell script \"\(command)\"")!
            dump(scriptObject.executeAndReturnError(&error).stringValue)
        }
    }
     
}
