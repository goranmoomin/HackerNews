
import Cocoa
import PromiseKit
import HackerNewsAPI
import Defaults

extension Defaults.Keys {
    static let accounts = Key<[String: String]>("accounts", default: [:])
    static let selectedAccount = Key<String?>("selectedAccount", default: nil)
}

class PrefsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var accountPopUp: NSPopUpButton!

    // MARK: - Properties

    var addNewMenuItem = NSMenuItem(title: "Add New...", action: #selector(addNewAccount), keyEquivalent: "")

    // MARK: - Methods

    @objc func addNewAccount() {
        let storyboard = NSStoryboard.main!
        let accountPopUpViewController = storyboard.instantiateController(identifier: .accountPopupViewController) as AccountPopupViewController
        accountPopUpViewController.delegate = self
        present(accountPopUpViewController, asPopoverRelativeTo: accountPopUp.frame, of: accountPopUp, preferredEdge: .maxY, behavior: .semitransient)
    }

    @objc func setAccount() {
        guard accountPopUp.selectedItem != addNewMenuItem, let account = accountPopUp.selectedItem?.title else {
            return
        }
        if let selectedAccount = Defaults[.selectedAccount], selectedAccount == account {
            Defaults[.selectedAccount] = nil
            accountPopUp.select(addNewMenuItem)
        } else {
            Defaults[.selectedAccount] = account
        }
        State.performLogin()
    }

    func updateInterface() {
        accountPopUp.removeAllItems()
        for (username, _) in Defaults[.accounts] {
            accountPopUp.menu?.addItem(NSMenuItem(title: username, action: #selector(setAccount), keyEquivalent: ""))
        }
        accountPopUp.menu?.addItem(.separator())
        accountPopUp.menu?.addItem(addNewMenuItem)
        if let selectedAccount = Defaults[.selectedAccount] {
            accountPopUp.selectItem(withTitle: selectedAccount)
        } else {
            accountPopUp.select(addNewMenuItem)
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        updateInterface()
    }
}

extension PrefsViewController: AccountPopupViewControllerDelegate {
    func addAccount(withUsername username: String, password: String) {
        Defaults[.accounts][username] = password
        updateInterface()
    }
}
