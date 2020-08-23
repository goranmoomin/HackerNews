
import Cocoa
import HNAPI

protocol ItemListViewControllerDelegate {
    func itemListSelectionDidChange(_ itemListViewController: ItemListViewController, selectedItem: TopLevelItem)
}

class ItemListViewController: NSViewController {

    @IBOutlet var itemListTableView: NSTableView!

    var delegate: ItemListViewControllerDelegate?

    var items: [TopLevelItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.itemListTableView.reloadData()
            }
        }
    }
    var category: HNAPI.Category! {
        didSet {
            APIClient.shared.items(category: category) { result in
                switch result {
                case .success(let items):
                    self.items = items
                case .failure(let error):
                    DispatchQueue.main.async {
                        NSApplication.shared.presentError(error)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        category = .top
    }
}

extension ItemListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        items[row]
    }
}

extension ItemListViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard itemListTableView.selectedRow >= 0 else {
            return
        }
        delegate?.itemListSelectionDidChange(self, selectedItem: items[itemListTableView.selectedRow])
    }
}
