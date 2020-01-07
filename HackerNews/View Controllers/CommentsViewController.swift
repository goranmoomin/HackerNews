
import Cocoa

class CommentsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var commentOutlineView: NSOutlineView!

    // MARK: - Properties

    // Always in sync with it's parent view controller
    var currentStory: Story? {
        didSet {
            commentOutlineView.reloadData()
            commentOutlineView.expandItem(nil, expandChildren: true)
        }
    }

    var commentCellViews: [CommentCellView] = []

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - CommentOutlineViewDelegate

extension CommentsViewController: CommentCellViewDelegate {

    func commentCellView(_ commentCellView: CommentCellView, toggleButtonWillBeClickedForComment comment: Comment?) {
        guard let comment = commentCellView.comment else {
            return
        }
        if commentOutlineView.isItemExpanded(comment) {
            commentOutlineView.collapseItem(comment, collapseChildren: true)
        } else {
            commentOutlineView.expandItem(comment, expandChildren: true)
        }
    }

    func commentCellView(_ commentCellView: CommentCellView, isCommentExpandable comment: Comment?) -> Bool {
        !(comment?.comments.isEmpty ?? true)
    }

    func commentCellView(_ commentCellView: CommentCellView, isCommentExpanded comment: Comment?) -> Bool {
        commentOutlineView.isItemExpanded(comment)
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

// MARK: - NSUserInterfaceItemIdentifier
extension NSUserInterfaceItemIdentifier {
    static let commentCellView = NSUserInterfaceItemIdentifier("CommentCellView")
}
