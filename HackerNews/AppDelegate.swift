
import Cocoa
import Combine
import HNAPI
import Defaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    static var shared: Self {
        NSApplication.shared.delegate as! Self
    }

    var token: Token?

    // MARK: - Global State

    @Published var category: HNAPI.Category = .top
    @Published var item: TopLevelItem?
    @Published var page: Page?

    // MARK: - Methods

    func performLogin() {
        guard
            let account = Defaults[.selectedAccount],
            let password = Defaults[.accounts][account] else {
            token = nil
            return
        }
        APIClient.shared.login(userName: account, password: password) { result in
            guard case let .success(token) = result else {
                // TODO: Handle failure
                return
            }
            self.token = token
        }
    }

    // MARK: - Lifecycle Methods

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        performLogin()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

