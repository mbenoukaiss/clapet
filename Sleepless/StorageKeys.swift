import SwiftUI

struct StorageKeys {
    static let automatic: String = "automatic"
    static let launchAtLogin: String = "launchAtLogin"
    static let showMenuIcon: String = "showMenuIcon"
    static let enableInactivityDelay: String = "enableInactivityDelay"
    static let inactivityDelay: String = "inactivityDelay"
    static let sleepDurations: String = "sleepDurations"
    
    static let defaults: [String: Any] = [
        StorageKeys.automatic: true,
        StorageKeys.launchAtLogin: false,
        StorageKeys.showMenuIcon: true,
        StorageKeys.enableInactivityDelay: true,
        StorageKeys.inactivityDelay: 15,
        StorageKeys.sleepDurations: [
            SleepDuration(id: UUID(), time: 15),
            SleepDuration(id: UUID(), time: 30),
            SleepDuration(id: UUID(), time: 60),
            SleepDuration(id: UUID(), time: 120),
        ],
    ]
    
    static func initializeDefaults() {
        UserDefaults.standard.register(defaults: defaults)
    }
    
    static func initial<T>(_ key: String) -> T {
        if let value = self.defaults[key] as? T {
            return value
        } else {
            fatalError("Invalid type for \(key)")
        }
    }
}
