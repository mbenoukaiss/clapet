import Foundation
import OSLog

struct Result {
    let success: Bool
    let output: String
}

class Shell {
    
    static let logger = Logger()
    
    static func run(_ command: String, admin: Bool = false, then: ((Result) -> Void)? = nil) {
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
    static func runSynchronous(_ command: String, admin: Bool = false) -> Result {
        var error: NSDictionary?
        let script = NSAppleScript(source: "do shell script \"\(command)\"" + (admin ? " with administrator privileges" : ""))!
        
        logger.trace("Running command \(command)")
        let output = script.executeAndReturnError(&error).stringValue
        
        if let error = error {
            logger.error("Failed to run \"\(command)\" with error : \(error.description)")
        }

        return Result(success: error == nil, output: output ?? "")
    }
    
}
