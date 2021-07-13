import Cocoa
import HNAPI

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let account = Account.selectedAccount {
            APIClient.shared.login(userName: account.username, password: account.password) {
                result in
                switch result {
                case .success(let token): Token.current = token
                case .failure(let error): NSApplication.shared.presentError(error)
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
