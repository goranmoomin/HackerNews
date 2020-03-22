
import Cocoa
import PromiseKit
import HackerNewsAPI

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
        if let selectedAccount = UserDefaults.standard.string(forKey: "selectedAccount"), selectedAccount == account {
            HackerNewsAPI.logout()
            UserDefaults.standard.set(nil, forKey: "selectedAccount")
            accountPopUp.select(addNewMenuItem)
        } else {
            UserDefaults.standard.set(account, forKey: "selectedAccount")
            if let accounts = UserDefaults.standard.dictionary(forKey: "accounts") as? [String: String], let password = accounts[account] {
                firstly {
                    HackerNewsAPI.login(toAccount: account, password: password)
                }.catch { error in
                    print(error)
                }
            }
        }
    }

    func updateInterface() {
        accountPopUp.removeAllItems()
        let accounts = UserDefaults.standard.dictionary(forKey: "accounts") ?? [:]
        for (username, _) in accounts {
            accountPopUp.menu?.addItem(NSMenuItem(title: username, action: #selector(setAccount), keyEquivalent: ""))
        }
        accountPopUp.menu?.addItem(.separator())
        accountPopUp.menu?.addItem(addNewMenuItem)
        if let selectedAccount = UserDefaults.standard.string(forKey: "selectedAccount") {
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
        print(username)
        print(password)
        var accounts = UserDefaults.standard.dictionary(forKey: "accounts") ?? [:]
        accounts[username] = password
        UserDefaults.standard.set(accounts, forKey: "accounts")
        updateInterface()
    }
}
