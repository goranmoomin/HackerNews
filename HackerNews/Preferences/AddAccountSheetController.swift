import Cocoa
import HNAPI

class AddAccountSheetController: NSViewController {

    @IBOutlet var usernameTextField: NSTextField!
    @IBOutlet var passwordTextField: NSTextField!
    @IBOutlet var spinner: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()  // Do view setup here.
    }

    @IBAction func signIn(_ sender: NSButton) {
        let username = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        usernameTextField.isEditable = false
        passwordTextField.isEditable = false
        spinner.startAnimation(self)
        APIClient.shared.login(userName: username, password: password) { result in
            DispatchQueue.main.async {
                self.spinner.stopAnimation(self)
                switch result {
                case .success(let token):
                    Account.addAccount(Account(username: username, password: password))
                    Account.selectAccount(withUsername: username)
                    Token.current = token
                case .failure(let error): NSApplication.shared.presentError(error)
                }
                let preferencesViewController =
                    self.presentingViewController as! PreferencesViewController
                self.dismiss(self)
                preferencesViewController.tableView.reloadData()
            }
        }
    }

    @IBAction func cancel(_ sender: NSButton) { dismiss(self) }
}
