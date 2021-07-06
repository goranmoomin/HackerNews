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
            Account.accounts.remove(at: tableView.selectedRow)
            tableView.reloadData()
        }
    }
}

extension PreferencesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { Account.accounts.count }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int)
        -> Any?
    { Account.accounts[row].username }
}

extension PreferencesViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else { return }
        let account = Account.accounts[tableView.selectedRow]
        Account.selectedAccountUsername = account.username
    }
}

extension NSStoryboard.SceneIdentifier {
    static var addAccountSheetController = NSStoryboard.SceneIdentifier("AddAccountSheetController")
}
