import Cocoa
import HNAPI

protocol ItemListViewControllerDelegate {
    func itemListSelectionDidChange(
        _ itemListViewController: ItemListViewController, selectedItem: TopLevelItem)
}

class ItemListViewController: NSViewController {

    @IBOutlet var itemListScrollView: NSScrollView!
    @IBOutlet var itemListTableView: NSTableView!
    @IBOutlet var spinner: NSProgressIndicator!

    var delegate: ItemListViewControllerDelegate?

    var isSearching = false
    var itemIds: [Int] = []
    var nextBatchStartIndex = 0
    var nextBatchItemIds: [Int] {
        guard itemIds.count >= nextBatchStartIndex + 30 else { return [] }
        return Array(itemIds[nextBatchStartIndex..<nextBatchStartIndex + 30])
    }
    var items: [TopLevelItem] = [] {
        didSet { DispatchQueue.main.async { self.itemListTableView.reloadData() } }
    }
    var category: HNAPI.Category! { didSet { reloadData() } }

    func reloadData() {
        isSearching = false
        itemIds = []
        items = []
        nextBatchStartIndex = 0
        spinner.startAnimation(self)
        let category = category!
        APIClient.shared.itemIds(category: category) { result in
            guard self.category == category else { return }
            switch result {
            case .success(let itemIds):
                self.itemIds = itemIds
                let nextBatchItemIds = self.nextBatchItemIds
                APIClient.shared.items(ids: nextBatchItemIds) { result in
                    guard self.nextBatchItemIds == nextBatchItemIds else { return }
                    DispatchQueue.main.async { self.spinner.stopAnimation(self) }
                    switch result {
                    case .success(let items):
                        self.items = items
                        self.nextBatchStartIndex += 30
                    case .failure(let error):
                        DispatchQueue.main.async { NSApplication.shared.presentError(error) }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(self)
                    NSApplication.shared.presentError(error)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        category = .top
        NotificationCenter.default.addObserver(
            self, selector: #selector(liveScrollDidEnd(_:)),
            name: NSScrollView.didEndLiveScrollNotification, object: nil)
    }

    @objc func refresh(_ sender: Any) { reloadData() }

    @IBAction func search(_ sender: NSSearchField) {
        let query = sender.stringValue
        if query == "" {
            isSearching = false
            reloadData()
        } else {
            isSearching = true
            items = []
            spinner.startAnimation(self)
            APIClient.shared.items(query: query) { result in
                DispatchQueue.main.async {
                    guard sender.stringValue == query else { return }
                    self.spinner.stopAnimation(self)
                    switch result {
                    case .success(let items): self.items = items
                    case .failure(let error): NSApplication.shared.presentError(error)
                    }
                }
            }
        }
    }

    @objc func liveScrollDidEnd(_ notification: Notification) {
        guard notification.object as AnyObject === itemListScrollView else { return }
        if !isSearching,
            let verticalScrollerFloatValue = itemListScrollView.verticalScroller?.floatValue,
            verticalScrollerFloatValue > 0.9
        {
            let nextBatchItemIds = nextBatchItemIds
            APIClient.shared.items(ids: nextBatchItemIds) { result in
                guard self.nextBatchItemIds == nextBatchItemIds else { return }
                switch result {
                case .success(let items):
                    self.items.append(contentsOf: items)
                    self.nextBatchStartIndex += 30
                case .failure(let error):
                    DispatchQueue.main.async { NSApplication.shared.presentError(error) }
                }
            }
        }
    }
}

extension ItemListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int { items.count }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int)
        -> Any?
    { items[row] }
}

extension ItemListViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard itemListTableView.selectedRow >= 0 else { return }
        delegate?
            .itemListSelectionDidChange(self, selectedItem: items[itemListTableView.selectedRow])
    }
}
