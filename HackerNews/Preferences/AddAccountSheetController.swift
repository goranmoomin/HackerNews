import Cocoa
import HNAPI

class AddAccountSheetController: NSViewController {

    @IBOutlet var usernameTextField: NSTextField!
    @IBOutlet var passwordTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()  // Do view setup here.
    }

    @IBAction func signIn(_ sender: NSButton) {
        let username = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        APIClient.shared.login(userName: username, password: password) { result in
            switch result {
            case .success(let token):
                Account.accounts.append(Account(username: username, password: password))
                Account.selectedAccountUsername = username
                Token.current = token
            case .failure(let error):
                DispatchQueue.main.async { NSApplication.shared.presentError(error) }
            }
            DispatchQueue.main.async {
                let preferencesViewController =
                    self.presentingViewController as! PreferencesViewController
                self.dismiss(self)
                preferencesViewController.tableView.reloadData()
            }
        }
    }

    @IBAction func cancel(_ sender: NSButton) { dismiss(self) }
}
