
import Cocoa

protocol AccountPopupViewControllerDelegate {
    func addAccount(withUsername username: String, password: String)
}

class AccountPopupViewController: NSViewController {

    // MARK: - Delegate

    var delegate: AccountPopupViewControllerDelegate?

    // MARK: - IBOutlets

    @IBOutlet var usernameTextField: NSTextField!
    @IBOutlet var passwordTextField: NSTextField!

    // MARK: - IBActions

    @IBAction func performLogin(_ sender: NSButton) {
        let username = usernameTextField.stringValue
        let password = passwordTextField.stringValue
        delegate?.addAccount(withUsername: username, password: password)
        if presentingViewController == nil {
            view.window?.close()
        } else {
            dismiss(self)
        }
    }
}

// MARK: - NSStoryboard.SceneIdentifier

extension NSStoryboard.SceneIdentifier {
    static var accountPopupViewController = NSStoryboard.SceneIdentifier("AccountPopupViewController")
}
