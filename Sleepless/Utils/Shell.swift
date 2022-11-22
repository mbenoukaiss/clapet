import Foundation
import OSLog

class Shell {
    
    static let logger = Logger()
    
    static func run(_ command: String, admin: Bool = false, then: ((Bool) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.runSynchronous(command, admin: admin)
            if let then = then {
                DispatchQueue.main.async {
                    then(result)
                }
            }
        }
    }
    
    @discardableResult
    static func runSynchronous(_ command: String, admin: Bool = false) -> Bool {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: "do shell script \"\(command)\"" + (admin ? " with administrator privileges" : ""))!
        
        logger.info("Running command \(command)")
        scriptObject.executeAndReturnError(&error)
        
        if let error = error {
            logger.error("Failed to run command with error : \(error.description)")
        }

        return error == nil
    }
    
}
