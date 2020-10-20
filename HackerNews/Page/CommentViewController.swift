
import Cocoa
import HNAPI

class CommentViewController: NSViewController {

    var page: Page? {
        didSet {
            DispatchQueue.main.async {
                self.commentOutlineView.reloadData()
            }
        }
    }

    var comments: [Comment] {
        page?.children ?? []
    }

    var actions: [Int : Set<Action>] {
        page?.actions ?? [:]
    }

    @IBOutlet var commentOutlineView: CommentOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension CommentViewController: CommentCellViewDelegate {
    func commentCellView(_ commentCellView: CommentCellView, actionsOf comment: Comment) -> Set<Action> {
        actions[comment.id] ?? []
    }

    func commentCellView(_ commentCellView: CommentCellView, execute action: Action, for comment: Comment) {
        guard let token = Account.selectedAccount?.token else { return }
        APIClient.shared.execute(action: action, token: token, page: page) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    commentCellView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    NSApplication.shared.presentError(error)
                }
            }
        }
    }

    func commentCellView(_ commentCellView: CommentCellView, replyTo comment: Comment) {
        let replyPopoverViewController = NSStoryboard.main?.instantiateController(withIdentifier: .commentReplyPopoverViewController) as! ReplyPopoverViewController
        replyPopoverViewController.title = "Comment to \(comment.author)"
        replyPopoverViewController.commentable = comment
        let popover = NSPopover()
        popover.contentViewController = replyPopoverViewController
        popover.delegate = replyPopoverViewController
        popover.show(relativeTo: .zero, of: commentCellView.replyButton, preferredEdge: .minY)
    }
}

extension CommentViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard item != nil else {
            return comments[index]
        }
        let comment = item as! Comment
        return comment.children[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let comment = item as! Comment
        return comment.children.count != 0
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard item != nil else {
            return comments.count
        }
        let comment = item as! Comment
        return comment.children.count
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        item
    }
}

extension CommentViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view = outlineView.makeView(withIdentifier: .commentCell, owner: self) as! CommentCellView
        view.delegate = self
        return view
    }
}
