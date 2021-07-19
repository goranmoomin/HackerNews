import Cocoa
import HNAPI

class PreferencesViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let index = Account.selectedAccountIndex {
            tableView.selectRowIndexes(IndexSet([index]), byExtendingSelection: false)
        }
    }

    @IBAction func addOrRemoveAccount(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let addAccountSheetController =
                NSStoryboard.main?.instantiateController(withIdentifier: .addAccountSheetController)
                as! AddAccountSheetController
            presentAsSheet(addAccountSheetController)
        } else if sender.selectedSegment == 1 {
            guard tableView.selectedRow != -1 else { return }
            let username = Account.accountUsernames[tableView.selectedRow]
            Account.removeAccount(withUsername: username)
            tableView.reloadData()
        }
    }
}

extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { Account.accountUsernames.count }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int)
        -> Any?
    { Account.accountUsernames[row] }
}

extension PreferencesViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else { return }
        let username = Account.accountUsernames[tableView.selectedRow]
        Account.selectAccount(withUsername: username)
        guard let account = Account.selectedAccount else { return }
        APIClient.shared.login(userName: account.username, password: account.password) { result in
            switch result {
            case .success(let token): Token.current = token
            case .failure(let error): NSApplication.shared.presentError(error)
            }
        }
    }
}

extension NSStoryboard.SceneIdentifier {
    static var addAccountSheetController = NSStoryboard.SceneIdentifier("AddAccountSheetController")
}
