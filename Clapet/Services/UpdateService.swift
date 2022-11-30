import AppKit
import SwiftUI
import OSLog

class UpdateService: ObservableObject {
    
    let logger = Logger()
    
    @AppStorage(StorageKeys.lastUpdateCheck)
    private var lastUpdateCheck: Date? = nil
    
    @AppStorage(StorageKeys.checkForUpdates)
    private var checkForUpdates: Bool = StorageDefaults.checkForUpdates
    
    @AppStorage(StorageKeys.skippedUpdates)
    private var skippedUpdates: [String] = StorageDefaults.skippedUpdates
    
    func periodicalUpdateCheck() {
        if !checkForUpdates {
            return
        }
        
        let limit = Calendar.current.date(
            byAdding: .day,
            value: -7,
            to: Date()
        )!
        
        if let lastUpdateCheck = lastUpdateCheck, lastUpdateCheck < limit {
            checkForUpdate(delay: 2)
        } else {
            logger.info("No update check needed yet")
        }
    }
    
    func checkForUpdate(delay: Int = 15) {
        if !checkForUpdates {
            return
        }
        
        let currentVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        
        AppDelegate.hideApplication()
        
        fetchGithubReleases(delay) {
            self.lastUpdateCheck = Date()
            
            let isUpdateAvailable = $0.tag_name != currentVersion
            
            if !isUpdateAvailable || self.skippedUpdates.contains($0.tag_name) {
                self.logger.info("No update found or skipped version")
                AppDelegate.hideApplication()
            } else {
                self.logger.info("Update \($0.tag_name) available")
                self.onUpdateFound(version: $0.tag_name)
            }
        }
    }
    
    private func fetchGithubReleases(_ delay: Int, then: @escaping (GithubRelease) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
            AppDelegate.showApplication();
            
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
    }
    
    private func onUpdateFound(version: String) {
        switch shouldDownload(version) {
            case .alertFirstButtonReturn:
                NSWorkspace.shared.open(URL(string: "https://github.com/mbenoukaiss/clapet/releases/latest")!)
            case .alertSecondButtonReturn:
                skippedUpdates.append(version)
            case .alertThirdButtonReturn: ()
            default: ()
        }
        
        AppDelegate.hideApplication()
    }
    
    private func shouldDownload(_ version: String) -> NSApplication.ModalResponse {
        let alert: NSAlert = NSAlert()
        alert.messageText = "update-available".localize(version)
        alert.informativeText = "update-available-description".localize()
        alert.alertStyle = .informational
        alert.addButton(withTitle: "download-version".localize())
        alert.addButton(withTitle: "skip-version".localize())
        alert.addButton(withTitle: "remind-me-later".localize())
        
        return alert.runModal()
    }
    
}

struct GithubRelease: Codable {
    let tag_name: String
}
