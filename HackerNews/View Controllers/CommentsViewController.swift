
import Cocoa
import PromiseKit

class CommentsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var commentOutlineView: NSOutlineView!

    // MARK: - Properties

    // Always in sync with it's parent view controller
    var currentStory: Story? {
        didSet {
            loadAndDisplayComments()
        }
    }

    var commentLoadProgress: Progress?
    var observation: NSKeyValueObservation?

    // MARK: - Methods

    func loadAndDisplayComments() {
        guard let currentStory = currentStory else {
            return
        }
        commentOutlineView.isHidden = true

        commentLoadProgress = Progress(totalUnitCount: 100)
        commentLoadProgress?.becomeCurrent(withPendingUnitCount: 100)

        firstly {
            HackerNewsAPI.loadComments(of: currentStory)
        }.done { _ in
            self.commentLoadProgress?.resignCurrent()
            self.commentLoadProgress = nil
            self.commentOutlineView.reloadData()
            self.commentOutlineView.expandItem(nil, expandChildren: true)
            self.commentOutlineView.isHidden = false
        }.catch { error in
            print(error)
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
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
        comment?.author ?? ""
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
