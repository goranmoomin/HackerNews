
import Cocoa
import PromiseKit

class CommentsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var commentOutlineView: NSOutlineView!
    @IBOutlet var progressView: ProgressView!

    // MARK: - Properties

    // Always in sync with it's parent view controller
    var currentStory: Story? {
        didSet {
            loadAndDisplayComments()
        }
    }

    var commentLoadProgress: Progress? {
        didSet {
            progressView.progress = commentLoadProgress
        }
    }
    var observation: NSKeyValueObservation?

    // MARK: - Methods

    func loadAndDisplayComments() {
        guard let currentStory = currentStory else {
            return
        }
        commentOutlineView.reloadData()
        commentOutlineView.isHidden = true

        let progress = Progress(totalUnitCount: 100)
        commentLoadProgress = progress
        progress.becomeCurrent(withPendingUnitCount: 100)

        firstly {
            HackerNewsAPI.loadComments(of: currentStory)
        }.done { _ in
            guard !progress.isCancelled else {
                return
            }
            self.commentLoadProgress = nil
            self.commentOutlineView.reloadData()
            self.commentOutlineView.expandItem(nil, expandChildren: true)
            self.commentOutlineView.isHidden = false
        }.catch { error in
            print(error)
        }
        progress.resignCurrent()
    }

    func initializeInterface() {
        progressView.labelText = "Loading Comments..."
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInterface()
    }
}

// MARK: - CommentOutlineViewDelegate

extension CommentsViewController: CommentCellViewDelegate {

    func formattedText(for comment: Comment?) -> String {
        let textData = comment?.text.data(using: .utf16) ?? Data()
        let attributedString = NSAttributedString(html: textData, documentAttributes: nil)
        return attributedString?.string.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func formattedAuthor(for comment: Comment?) -> String {
        comment?.authorName ?? ""
    }

    func formattedDate(for comment: Comment?) -> String {
        guard let comment = comment else {
            return ""
        }
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.formattingContext = .standalone
        dateFormatter.dateTimeStyle = .named
        return dateFormatter.localizedString(for: comment.time, relativeTo: Date())
    }

    func toggle(_ comment: Comment?) {
        guard let comment = comment else {
            return
        }
        if commentOutlineView.isItemExpanded(comment) {
            commentOutlineView.collapseItem(comment, collapseChildren: true)
        } else {
            commentOutlineView.expandItem(comment, expandChildren: true)
        }
    }

    func isToggleHidden(for comment: Comment?) -> Bool {
        comment?.comments.isEmpty ?? true
    }

    func isToggleExpanded(for comment: Comment?) -> Bool {
        commentOutlineView.isItemExpanded(comment)
    }

    func formattedToggleCount(for comment: Comment?) -> String {
        guard !isToggleExpanded(for: comment), let comment = comment, comment.commentCount != 1 else {
            return ""
        }
        return "\(comment.commentCount) replies hidden"
    }

    func displayPopup(for comment: Comment?, relativeTo rect: NSRect, of view: CommentCellView) {
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: .authorPopupViewController) as! AuthorPopupViewController
        viewController.userName = comment?.authorName
        let popover = NSPopover()
        popover.contentViewController = viewController
        popover.behavior = .transient
        popover.show(relativeTo: rect, of: view, preferredEdge: .minY)
    }
}

// MARK: - NSOutlineViewDataSource

extension CommentsViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let comment = item as? Comment else {
            return currentStory!.comments[index]
        }
        return comment.comments[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let comment = item as? Comment else {
            return false
        }
        return !comment.comments.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let comment = item as? Comment else {
            return currentStory?.comments.count ?? 0
        }
        return comment.comments.count
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
        outlineView.makeView(withIdentifier: .commentCellView, owner: self)
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


// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {

    static let commentCellView = NSUserInterfaceItemIdentifier("CommentCellView")
}
