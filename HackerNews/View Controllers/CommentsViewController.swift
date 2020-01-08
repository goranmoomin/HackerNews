
import Cocoa
import PromiseKit

class CommentsViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var commentOutlineView: NSOutlineView!
    @IBOutlet var progressBar: NSProgressIndicator!

    // MARK: - Properties

    // Always in sync with it's parent view controller
    var currentStory: Story? {
        didSet {
            loadAndDisplayComments()
        }
    }

    var commentLoadProgress: Progress? {
        didSet {
            observation = commentLoadProgress?.observe(\.fractionCompleted) { progress, _ in
                self.progressBar.doubleValue = progress.fractionCompleted
            }
        }
    }
    var observation: NSKeyValueObservation?

    // MARK: - Methods

    func loadAndDisplayComments() {
        guard let currentStory = currentStory else {
            return
        }
        progressBar.isHidden = false
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
            self.progressBar.isHidden = true
            self.progressBar.doubleValue = 0
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
        return attributedString?.string ?? ""
    }

    func formattedAuthor(for comment: Comment?) -> String {
        comment?.author ?? ""
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
