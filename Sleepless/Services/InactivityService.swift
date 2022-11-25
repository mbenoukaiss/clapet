import OSLog
import SwiftUI

class InactivityService: ObservableObject {
    
    static let defaultDelay: Int = 15
    
    let logger = Logger()
    
    @AppStorage(StorageKeys.inactivityDelay)
    private var delay: Int = StorageDefaults.inactivityDelay
    
    func setDelay(delay: Int) {
        if delay == 0 {
            return
        }
        
        self.delay = delay
    }
    
    @discardableResult
    func onInactive(_ then: @escaping () -> Void) -> Timer {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            self.getAssertions() { assertions in
                //if there's an app preventing sleep (movie, video, etc)
                //then inactivity timer shouldn't fire
                if assertions["PreventUserIdleDisplaySleep"] ?? false {
                    return;
                }
                
                let delay = Double(self.delay) * 60.0
                let lastEvent = CGEventSource.secondsSinceLastEventType(
                    CGEventSourceStateID.hidSystemState,
                    eventType: CGEventType(rawValue: ~0)!
                )
                
                if lastEvent > delay {
                    self.logger.info("Computer has been inactive for \(delay), triggering onInactive callback")
                    then()
                    
                    timer.invalidate()
                }
            }
        }
    }
    
    func getAssertions(then: @escaping ([String: Bool]) -> Void) {
        let pattern = #"^ {3}([A-Za-z]+) +(0|1)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            fatalError("Invalid regex: \(pattern)")
        }
        
        Shell.run("pmset -g assertions") {
            var assertions: [String: Bool] = [:]
            
            for line in $0.output.split(whereSeparator: \.isNewline) {
                let nsLine = line as NSString
                let matches = regex.matches(in: String(line), options: [], range: NSMakeRange(0, nsLine.length))
                
                if matches.count == 1 {
                    let lineMatches = matches[0]
                    if lineMatches.numberOfRanges == 3 {
                        let assertion = String(nsLine.substring(with: lineMatches.range(at: 1)))
                        let value = nsLine.substring(with: lineMatches.range(at: 2)) == "1"
                        
                        assertions[assertion] = value
                    }
                }
            }
            
            then(assertions)
        }
    }
    
}
