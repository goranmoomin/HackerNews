
import Cocoa
import HNAPI
import Atributika

protocol CommentCellViewDelegate {
    func commentCellView(_ commentCellView: CommentCellView, actionsOf comment: Comment) -> Set<Action>
    func commentCellView(_ commentCellView: CommentCellView, execute action: Action, for comment: Comment)
}

class CommentCellView: NSTableCellView {

    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var creationLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var upvoteButton: VoteButton!
    @IBOutlet var downvoteButton: VoteButton!

    let formatter = RelativeDateTimeFormatter()

    var delegate: CommentCellViewDelegate?

    override var objectValue: Any? {
        didSet {
            reloadData()
        }
    }

    func reloadData() {
        guard objectValue != nil else {
            return
        }
        let comment = objectValue as! Comment
        let actions = delegate?.commentCellView(self, actionsOf: comment) ?? []
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        for action in actions {
            switch action {
            case .upvote:
                upvoteButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                upvoteButton.isHidden = false
                upvoteButton.voteAction = action
            case .unvote:
                upvoteButton.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                upvoteButton.isHidden = false
                upvoteButton.voteAction = action
            case .downvote:
                downvoteButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                downvoteButton.isHidden = false
                downvoteButton.voteAction = action
            case .undown:
                downvoteButton.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                downvoteButton.isHidden = false
                downvoteButton.voteAction = action
            default: break
            }
        }
        authorLabel.stringValue = comment.author
        textLabel.attributedStringValue = comment.text.styledAttributedString
        creationLabel.stringValue = formatter.localizedString(for: comment.creation, relativeTo: Date())
    }

    @IBAction func executeAction(_ sender: VoteButton) {
        guard objectValue != nil,
              let action = sender.voteAction else {
            return
        }
        let comment = objectValue as! Comment
        delegate?.commentCellView(self, execute: action, for: comment)
    }
}

extension NSUserInterfaceItemIdentifier {
    static let commentCell = NSUserInterfaceItemIdentifier("CommentCell")
}
