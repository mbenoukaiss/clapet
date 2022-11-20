import SwiftUI

struct StorageKeys {
    static let automatic: String = "automatic"
    static let launchAtLogin: String = "launchAtLogin"
    static let showMenuIcon: String = "showMenuIcon"
    static let automaticSwitchNotification: String = "automaticSwitchNotification"
    static let enableInactivityDelay: String = "enableInactivityDelay"
    static let inactivityDelay: String = "inactivityDelay"
    static let sleepDurations: String = "sleepDurations"
    
    static let defaults: [String: Any] = [
        StorageKeys.automatic: true,
        StorageKeys.launchAtLogin: false,
        StorageKeys.showMenuIcon: true,
        StorageKeys.automaticSwitchNotification: false,
        StorageKeys.enableInactivityDelay: true,
        StorageKeys.inactivityDelay: 15,
        StorageKeys.sleepDurations: [
            SleepDuration(id: UUID(uuidString: "1565478a-54e7-4f3f-8bda-0734a0d3f4c0").unsafelyUnwrapped, time: 15),
            SleepDuration(id: UUID(uuidString: "e8f39c4a-574f-472a-a339-41ea1af7d2e4").unsafelyUnwrapped, time: 30),
            SleepDuration(id: UUID(uuidString: "b2dbde49-b438-4530-8f1b-421f70b1b05c").unsafelyUnwrapped, time: 60),
            SleepDuration(id: UUID(uuidString: "a01e96c6-806a-4638-b0ad-902176932e63").unsafelyUnwrapped, time: 120),
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
