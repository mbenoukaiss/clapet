import Foundation
import OSLog

class SleepService: ObservableObject {
    
    let logger = Logger()
    
    private var inactivityService: InactivityService
    
    @Published
    var enabled: Bool = true
    
    var pendingWork: DispatchWorkItem? = nil
    var inactivityTimer: Timer? = nil
    
    init(inactivityService: InactivityService) {
        self.inactivityService = inactivityService
    }
    
    func isAutomaticOverriden() -> Bool {
        return self.pendingWork != nil
    }
    
    func disable(withTimer: Bool = true) {
        logger.info("Disabling sleep")
        enabled = false
        
        if let inactivityTimer = self.inactivityTimer {
            inactivityTimer.invalidate()
        }
        
        if withTimer {
            //enable sleep after delay of inactivity so the
            //battery doesn't get emptied if the user forgot
            //to turn off sleepless (default delay: 15m)
            self.inactivityTimer = inactivityService.onInactive {
                self.enable()
            }
        }
        
        self.run("sudo pmset -b sleep 0; sudo pmset -b disablesleep 1");
    }
    
    func disableFor(_ delay: Int) {
        //disable without inactivity timer because we
        //create our own timer regardless of activity
        self.disable(withTimer: false)
        
        self.cancelDisableFor()
        
        pendingWork = DispatchWorkItem(block: {
            self.enable()
            //todo: notification
            
            self.pendingWork = nil
        })
        
        logger.info("Waiting \(delay) minutes to enable sleep again")
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Double(delay * 60),
            execute: pendingWork.unsafelyUnwrapped
        )
    }
    
    func cancelDisableFor() {
        if let work = self.pendingWork {
            work.cancel()
        }
        
        self.pendingWork = nil
    }
    
    func enable() {
        logger.info("Enabling sleep")
        self.enabled = true
        self.cancelDisableFor()
        
        self.run("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
    }
    
    func enableSynchronous() {
        logger.info("Enabling sleep")
        self.enabled = true
        self.cancelDisableFor()
        
        self.runSynchronous("sudo pmset -b sleep 5; sudo pmset -b disablesleep 0");
    }
    
    func run(_ command: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.runSynchronous(command)
        }
    }
    
    func runSynchronous(_ command: String) {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: "do shell script \"\(command)\"")!
        
        self.logger.info("Running command \(command)")
        scriptObject.executeAndReturnError(&error)
        
        if let error = error {
            self.logger.error("Failed to run command with error : \(error.description)")
        }
    }
     
}
