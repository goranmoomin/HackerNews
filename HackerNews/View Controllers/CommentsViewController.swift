
import Cocoa
import Combine
import HNAPI

class CommentsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var itemDetailsView: ItemDetailsView!
    @IBOutlet var commentScrollView: NSScrollView!
    @IBOutlet var commentOutlineView: NSOutlineView!
    @IBOutlet var progressView: ProgressView!

    // MARK: - Properties

    var page: Page? {
        get {
            AppDelegate.shared.page
        }
        set {
            AppDelegate.shared.page = newValue
        }
    }

    var commentLoadProgress: Progress? {
        didSet {
            progressView.progress = commentLoadProgress
        }
    }

    var cancellables: Set<AnyCancellable> = []

    // MARK: - Methods

    func loadAndDisplayComments(item: TopLevelItem?) {
        guard let item = item else {
            // Clear UI
            return
        }
        commentOutlineView.reloadData()
        commentOutlineView.isHidden = true

        let progress = Progress(totalUnitCount: 100)
        commentLoadProgress = progress
        progress.becomeCurrent(withPendingUnitCount: 100)
        APIClient.shared.page(item: item, token: AppDelegate.shared.token) { result in
            DispatchQueue.main.async {
                self.commentLoadProgress = nil
                guard case let .success(page) = result else {
                    return
                }
                self.page = page
                self.itemDetailsView.isHidden = false
                self.itemDetailsView.page = page
                self.commentOutlineView.reloadData()
                self.commentOutlineView.expandItem(nil, expandChildren: true)
                self.commentOutlineView.isHidden = false
            }
        }
        progress.resignCurrent()
    }

    func initializeInterface() {
        progressView.labelText = "Loading Comments..."
        AppDelegate.shared.$item
            .sink(receiveValue: loadAndDisplayComments(item:))
            .store(in: &cancellables)
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInterface()
    }

    var itemDetailsViewConstraint: NSLayoutConstraint?

    override func updateViewConstraints() {
        if itemDetailsViewConstraint == nil, let contentLayoutGuide = view.window?.contentLayoutGuide as? NSLayoutGuide {
            let contentTopAnchor = contentLayoutGuide.topAnchor
            itemDetailsViewConstraint = itemDetailsView.topAnchor.constraint(equalTo: contentTopAnchor)
            itemDetailsViewConstraint?.isActive = true
        }
        super.updateViewConstraints()
    }
}

// MARK: - CommentCellViewDelegate

extension CommentsViewController: CommentCellViewDelegate {

    func expandComments(for comment: Comment) {
        commentOutlineView.expandItem(comment)
    }

    func collapseComments(for comment: Comment) {
        commentOutlineView.collapseItem(comment)
    }

    func isCommentsHidden(for comment: Comment) -> Bool {
        !commentOutlineView.isItemExpanded(comment)
    }
}

// MARK: - NSOutlineViewDataSource

extension CommentsViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let page = page else {
            fatalError()
        }
        if item == nil {
            return page.children[index]
        } else if let comment = item as? Comment {
            return comment.children[index]
        } else {
            fatalError()
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let comment = item as? Comment else {
            return false
        }
        return !comment.children.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let page = page else {
            return 0
        }
        if item == nil {
            return page.children.count
        } else if let comment = item as? Comment {
            return comment.children.count
        } else {
            fatalError()
        }
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        guard let comment = item as? Comment else {
            return nil
        }
        return comment
    }
}

// MARK: - NSOutlineViewDelegate

extension CommentsViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        // objectValue is automatically populated
        let commentCellView = outlineView.makeView(withIdentifier: .commentCellView, owner: self) as! CommentCellView
        commentCellView.delegate = self
        return commentCellView
    }
}

// MARK: - NSStoryboard.Name

extension NSStoryboard.Name {

    static let main = NSStoryboard.Name("Main")
}

// MARK: - NSStoryboard.SceneIdentifier

extension NSStoryboard.SceneIdentifier {

    static let authorPopupViewController = NSStoryboard.SceneIdentifier("AuthorPopupViewController")
}
