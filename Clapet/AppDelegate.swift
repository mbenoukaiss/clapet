import AppKit
import SwiftUI
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    
    let logger = Logger()
    
    @AppStorage(StorageKeys.alreadySetup)
    private var alreadySetup: Bool = StorageDefaults.alreadySetup
    
    @AppStorage(StorageKeys.skippedUpdates)
    private var skippedUpdates: [String] = StorageDefaults.skippedUpdates
    
    func applicationDidFinishLaunching(_: Notification) {
        let currentVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        
        if alreadySetup {
            checkForUpdates() {
                let isUpdateAvailable = $0.tag_name != currentVersion
                
                if !isUpdateAvailable || self.skippedUpdates.contains($0.tag_name) {
                    self.logger.info("No update found or skipped version")
                    self.hideApplication()
                } else {
                    self.logger.info("Update \($0.tag_name) available")
                    self.onUpdateFound(version: $0.tag_name)
                }
            }
        }
    }
    
    func checkForUpdates(then: @escaping (GithubRelease) -> Void) {
        let url = URL(string: "https://api.github.com/repos/mbenoukaiss/clapet/releases/latest")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = try? JSONDecoder().decode(GithubRelease.self, from: data) {
                DispatchQueue.main.async {
                    then(response)
                }
            }
        }.resume()
    }
    
    func onUpdateFound(version: String) {
        switch shouldDownload(version) {
            case .alertFirstButtonReturn:
                NSWorkspace.shared.open(URL(string: "https://github.com/mbenoukaiss/clapet/releases/latest")!)
            case .alertSecondButtonReturn:
                skippedUpdates.append(version)
            case .alertThirdButtonReturn:
                break
            default:
                break
        }
        
        hideApplication()
    }
    
    func shouldDownload(_ version: String) -> NSApplication.ModalResponse {
        let alert: NSAlert = NSAlert()
        alert.messageText = "update-available".localize(version)
        alert.informativeText = "update-available-description".localize()
        alert.alertStyle = .informational
        alert.addButton(withTitle: "download-version".localize())
        alert.addButton(withTitle: "skip-version".localize())
        alert.addButton(withTitle: "remind-me-later".localize())
        
        return alert.runModal()
    }
    
    func hideApplication() {
        NSApp.setActivationPolicy(.prohibited)
    }
    
}

struct GithubRelease: Codable {
    let tag_name: String
}
