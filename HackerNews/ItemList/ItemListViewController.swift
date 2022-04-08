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
    var category: HNAPI.Category! { didSet { Task { await self.reloadData() } } }

    func reloadData() async {
        isSearching = false
        itemIds = []
        items = []
        nextBatchStartIndex = 0
        Task { self.spinner.startAnimation(self) }
        let category = category!
        do {
            let itemIds = try await APIClient.shared.itemIds(category: category)
            guard self.category == category else { return }
            self.itemIds = itemIds
            let nextBatchItemIds = self.nextBatchItemIds
            let items = try await APIClient.shared.items(ids: nextBatchItemIds)
            guard self.nextBatchItemIds == nextBatchItemIds else { return }
            Task { self.spinner.stopAnimation(self) }
            self.items = items
            self.nextBatchStartIndex += 30
        } catch let error {
            Task {
                self.spinner.stopAnimation(self)
                NSApplication.shared.presentError(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        category = .top
    }

    @objc func refresh(_ sender: Any) { Task { await self.reloadData() } }

    @IBAction func search(_ sender: NSSearchField) {
        let query = sender.stringValue
        if query == "" {
            isSearching = false
            Task { await self.reloadData() }
        } else {
            Task {
                isSearching = true
                items = []
                spinner.startAnimation(self)
                do {
                    let items = try await APIClient.shared.items(query: query)
                    guard sender.stringValue == query else { return }
                    self.spinner.stopAnimation(self)
                    self.items = items
                    self.itemIds = items.map(\.id)
                } catch {
                    self.spinner.stopAnimation(self)
                    NSApplication.shared.presentError(error)
                }
            }
        }
    }

    func startLoadingNextBatch() async {
        let nextBatchItemIds = nextBatchItemIds
        do {
            let items1 = try await APIClient.shared.items(ids: nextBatchItemIds)
            guard self.nextBatchItemIds == nextBatchItemIds else { return }
            self.items.append(contentsOf: items1)
            self.nextBatchStartIndex += 30
        } catch let error { Task { NSApplication.shared.presentError(error) } }
    }
}

extension ItemListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard items.count > 0 else { return 0 }
        return min(items.count + 1, itemIds.count)
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int)
        -> Any?
    { if row < items.count { return items[row] } else { return nil } }
}

extension ItemListViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard itemListTableView.selectedRow >= 0 else { return }
        delegate?
            .itemListSelectionDidChange(self, selectedItem: items[itemListTableView.selectedRow])
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int)
        -> NSView?
    {
        if row < items.count {
            return tableView.makeView(withIdentifier: .itemListCellView, owner: self)
        } else {
            guard items.count < itemIds.count else { return nil }
            let loadingView =
                tableView.makeView(withIdentifier: .itemListLoadingCellView, owner: self)
                as! ItemListCellLoadingView
            loadingView.spinner.startAnimation(self)
            Task { await startLoadingNextBatch() }
            return loadingView
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    static let itemListCellView = NSUserInterfaceItemIdentifier("ItemListCellView")
    static let itemListLoadingCellView = NSUserInterfaceItemIdentifier("ItemListLoadingCellView")
}
