
import Cocoa
import HNAPI

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

    var items: [TopLevelItem] = [] {
        didSet {
            itemTableView.reloadData()
        }
    }

    var category: HNAPI.Category = .top {
        didSet {
            loadAndDisplayItems()
        }
    }

    var item: TopLevelItem? {
        get {
            splitViewController.item
        }
        set {
            splitViewController.item = newValue
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
        APIClient.shared.items(category: category) { result in
            DispatchQueue.main.async {
                self.storyLoadProgress = nil
                guard case let .success(items) = result else {
                    // TODO: Error handling
                    return
                }
                self.items = items
                self.itemTableView.isHidden = false
            }
        }
        progress.resignCurrent()
    }

    func searchAndDisplayItems(matching query: String) {
        // TODO
    }

    func initializeInterface() {
        storySearchView.delegate = self
        storySearchView.isHidden = true
        progressView.labelText = "Loading Items..."
        itemScrollView.automaticallyAdjustsContentInsets = false
    }

    func updateContentInsets() {
        let window = view.window!
        let contentLayoutRect = window.contentLayoutRect
//        let storySearchViewHeight = storySearchView.frame.height
        let topInset = (window.contentView!.frame.size.height - contentLayoutRect.height) // + storySearchViewHeight
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

    func open(item: TopLevelItem) {
        let content: Content
        switch item {
        case let .story(story):
            content = story.content
        case let .job(job):
            content = job.content
        }
        guard let url = content.url else {
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
        item = items[itemTableView.selectedRow]
    }
}
