
import Cocoa
import PromiseKit
import HackerNewsAPI

class ItemsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var itemScrollView: NSScrollView!
    @IBOutlet var itemTableView: NSTableView!
    @IBOutlet var progressView: ProgressView!
    @IBOutlet var storySearchView: ItemSearchView!

    // MARK: - Parent View Controller

    var splitViewController: SplitViewController {
        parent as! SplitViewController
    }

    // MARK: - Properties

    var items: [ListableItem] = [] {
        didSet {
            itemTableView.reloadData()
        }
    }

    var currentCategory: ItemListCategory = .top {
        didSet {
            loadAndDisplayItems()
        }
    }

    var currentToken: Token? {
        State.shared.currentToken
    }

    var selectedItem: ListableItem? {
        get {
            splitViewController.currentListableItem
        }
        set {
            splitViewController.currentListableItem = newValue
        }
    }

    var storyLoadProgress: Progress? {
        willSet {
            storyLoadProgress?.cancel()
        }
        didSet {
            progressView.progress = storyLoadProgress
        }
    }

    // MARK: - Methods

    func loadAndDisplayItems(count: Int = 10) {
        items = []
        itemTableView.isHidden = true

        let progress = Progress(totalUnitCount: 100)
        storyLoadProgress = progress
        progress.becomeCurrent(withPendingUnitCount: 100)
        firstly {
            HackerNewsAPI.items(from: currentCategory, token: currentToken)
        }.done { items in
            guard !progress.isCancelled else {
                return
            }
            self.storyLoadProgress = nil
            self.items = items
            self.itemTableView.isHidden = false
        }.catch { error in
            print(error)
        }
        progress.resignCurrent()
    }

    func searchAndDisplayItems(matching query: String) {
        // TODO
    }

    func initializeInterface() {
        storySearchView.delegate = self
        progressView.labelText = "Loading Items..."
        itemScrollView.automaticallyAdjustsContentInsets = false
    }

    func updateContentInsets() {
        let window = view.window!
        let contentLayoutRect = window.contentLayoutRect
        let storySearchViewHeight = storySearchView.frame.height
        let topInset = (window.contentView!.frame.size.height - contentLayoutRect.height) + storySearchViewHeight
        itemScrollView.contentInsets = NSEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInterface()
        loadAndDisplayItems()
    }

    var contentLayoutRectObservation: NSKeyValueObservation?

    override func viewWillAppear() {
        super.viewWillAppear()
        contentLayoutRectObservation = view.window!.observe(\.contentLayoutRect) { _, _ in
            self.updateContentInsets()
        }
    }

    var storySearchViewConstraint: NSLayoutConstraint?

    override func updateViewConstraints() {
        if storySearchViewConstraint == nil, let contentLayoutGuide = view.window?.contentLayoutGuide as? NSLayoutGuide {
            let contentTopAnchor = contentLayoutGuide.topAnchor
            storySearchViewConstraint = storySearchView.topAnchor.constraint(equalTo: contentTopAnchor)
            storySearchViewConstraint?.isActive = true
        }
        super.updateViewConstraints()
    }
}

// MARK: - ListableItemCellViewDelegate

extension ItemsViewController: ListableItemCellViewDelegate {

    func open(item: ListableItem) {
        guard let url = item.url else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

// MARK: - ItemSearchViewDelegate

extension ItemsViewController: ItemSearchViewDelegate {

    func searchItems(matching query: String) {
        searchAndDisplayItems(matching: query)
    }

    func reloadItems(count: Int) {
        loadAndDisplayItems(count: count)
    }
}

// MARK: - NSTableViewDataSource

extension ItemsViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        items[row]
    }
}

// MARK: - NSTableViewDelegate

extension ItemsViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // objectValue is automatically populated
        let storyCellView = tableView.makeView(withIdentifier: .listableItemCellView, owner: self) as! ListableItemCellView
        storyCellView.delegate = self
        return storyCellView
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        tableView.makeView(withIdentifier: .itemRowView, owner: self) as? ItemRowView
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedItem = items[itemTableView.selectedRow]
    }
}
