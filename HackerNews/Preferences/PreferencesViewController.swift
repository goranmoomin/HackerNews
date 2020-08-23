
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

    @IBAction func removeAccount(_ sender: NSButton) {
        guard tableView.selectedRow != -1 else {
            return
        }
        Account.accounts.remove(at: tableView.selectedRow)
        if Account.accounts.count > 1 {
            Account.selectedAccountIndex! -= 1
        } else {
            Account.selectedAccountIndex = nil
        }
        tableView.reloadData()
    }
}

extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        Account.accounts.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        Account.accounts[row].username
    }
}

extension PreferencesViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else {
            return
        }
        Account.selectedAccountIndex = tableView.selectedRow
    }
}
