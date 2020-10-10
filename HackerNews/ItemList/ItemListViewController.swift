
import Cocoa
import HNAPI

protocol ItemListViewControllerDelegate {
    func itemListSelectionDidChange(_ itemListViewController: ItemListViewController, selectedItem: TopLevelItem)
}

class ItemListViewController: NSViewController {

    @IBOutlet var itemListTableView: NSTableView!
    @IBOutlet var spinner: NSProgressIndicator!

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
            reloadData()
        }
    }

    func reloadData() {
        items = []
        spinner.startAnimation(self)
        APIClient.shared.items(category: category) { result in
            DispatchQueue.main.async {
                self.spinner.stopAnimation(self)
            }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        category = .top
    }

    @IBAction func search(_ sender: NSSearchField) {
        let query = sender.stringValue
        if query == "" {
            reloadData()
        } else {
            items = []
            spinner.startAnimation(self)
            APIClient.shared.items(query: query) { result in
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(self)
                }
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
