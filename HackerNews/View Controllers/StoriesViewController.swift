
import Cocoa
import PromiseKit
import HackerNewsAPI

class StoriesViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var storyScrollView: NSScrollView!
    @IBOutlet var storyTableView: NSTableView!
    @IBOutlet var progressView: ProgressView!
    @IBOutlet var storySearchView: StorySearchView!

    // MARK: - Parent View Controller

    var splitViewController: SplitViewController {
        parent as! SplitViewController
    }

    // MARK: - Properties

    var items: [ListableItem] = [] {
        didSet {
            storyTableView.reloadData()
        }
    }

    var stories: [LegacyStoryable] = [] {
        didSet {
            storyTableView.reloadData()
        }
    }

    var currentCategory: LegacyCategory = .topStories {
        didSet {
            loadAndDisplayStories()
        }
    }

    var selectedItem: ListableItem? {
        get {
            splitViewController.currentItem
        }
        set {
            splitViewController.currentItem = newValue
        }
    }

    var selectedStory: LegacyStory? {
        get {
            splitViewController.currentStory
        }
        set {
            splitViewController.currentStory = newValue
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

    func loadAndDisplayStories(count: Int = 10) {
        stories = []
        self.storyTableView.isHidden = true

        firstly {
            HackerNewsAPI.topItems()
        }.done { items in
            self.items = items
        }.catch { error in
            print(error)
        }

        let progress = Progress(totalUnitCount: 100)
        storyLoadProgress = progress
        progress.becomeCurrent(withPendingUnitCount: 100)
        firstly {
            LegacyHackerNewsAPI.stories(from: currentCategory, count: count)
        }.done { stories in
            guard !progress.isCancelled else {
                return
            }
            self.storyLoadProgress = nil
            self.stories = stories
            self.storyTableView.isHidden = false
        }.catch { error in
            print(error)
        }
        progress.resignCurrent()
    }

    func searchAndDisplayStories(matching query: String) {
        stories = []
        self.storyTableView.isHidden = true

        let progress = Progress(totalUnitCount: 100)
        storyLoadProgress = progress
        progress.becomeCurrent(withPendingUnitCount: 100)
        firstly {
            LegacyHackerNewsAPI.stories(matching: query)
        }.done { stories in
            guard !progress.isCancelled else {
                return
            }
            self.storyLoadProgress = nil
            self.stories = stories
            self.storyTableView.isHidden = false
        }.catch { error in
            print(error)
        }
        progress.resignCurrent()
    }

    func initializeInterface() {
        storySearchView.delegate = self
        progressView.labelText = "Loading Stories..."
        storyScrollView.automaticallyAdjustsContentInsets = false
        firstly {
            LegacyHackerNewsAPI.interactionManager.login(toAccount: "pcr910303", withPassword: "Josungbin3072810")
        }.catch { error in
            print(error)
        }
    }

    func updateContentInsets() {
        let window = view.window!
        let contentLayoutRect = window.contentLayoutRect
        let storySearchViewHeight = storySearchView.frame.height
        let topInset = (window.contentView!.frame.size.height - contentLayoutRect.height) + storySearchViewHeight
        storyScrollView.contentInsets = NSEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInterface()
        loadAndDisplayStories()
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

// MARK: - StorySearchViewDelegate

extension StoriesViewController: StorySearchViewDelegate {

    func searchStories(matching query: String) {
        searchAndDisplayStories(matching: query)
    }

    func reloadStories(count: Int) {
        loadAndDisplayStories(count: count)
    }
}

// MARK: - NSTableViewDataSource

extension StoriesViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        items[row]
    }
}

// MARK: - NSTableViewDelegate

extension StoriesViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // objectValue is automatically populated
        let storyCellView = tableView.makeView(withIdentifier: .listableItemCellView, owner: self) as! ListableItemCellView
        return storyCellView
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        tableView.makeView(withIdentifier: .storyRowView, owner: self) as? StoryRowView
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedItem = items[storyTableView.selectedRow]
        selectedStory = stories[storyTableView.selectedRow] as? LegacyStory
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {

    static let storyRowView = NSUserInterfaceItemIdentifier("StoryRowView")
}
