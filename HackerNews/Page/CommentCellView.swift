import Atributika
import Cocoa
import HNAPI

protocol CommentCellViewDelegate {
    func commentCellView(_ commentCellView: CommentCellView, actionsOf comment: Comment) -> Set<
        Action
    >
    func commentCellView(
        _ commentCellView: CommentCellView, execute action: Action, for comment: Comment)
    func commentCellView(_ commentCellView: CommentCellView, replyTo comment: Comment)
}

class CommentCellView: NSTableCellView {

    @IBOutlet var propertiesStackView: NSStackView!
    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var creationLabel: NSTextField!
    @IBOutlet var textView: NSTextView!
    @IBOutlet var upvoteButton: NSButton!
    @IBOutlet var downvoteButton: NSButton!
    @IBOutlet var replyButton: NSButton!
    var upvoteAction: Action?
    var downvoteAction: Action?

    let formatter = RelativeDateTimeFormatter()

    var delegate: CommentCellViewDelegate?

    override var objectValue: Any? { didSet { reloadData() } }

    func reloadData() {
        guard objectValue != nil else { return }
        let comment = objectValue as! Comment
        let actions = delegate?.commentCellView(self, actionsOf: comment) ?? []
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        for action in actions {
            switch action {
            case .upvote:
                upvoteButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                upvoteButton.isHidden = false
                upvoteAction = action
            case .unvote:
                upvoteButton.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                upvoteButton.isHidden = false
                upvoteAction = action
            case .downvote:
                downvoteButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                downvoteButton.isHidden = false
                downvoteAction = action
            case .undown:
                downvoteButton.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                downvoteButton.isHidden = false
                downvoteAction = action
            default: break
            }
        }
        authorLabel.stringValue = comment.author
        let textColor: NSColor
        switch comment.color {
        case .c00: textColor = .labelColor
        case .c5a, .c73, .c82: textColor = .secondaryLabelColor
        case .c88, .c9c, .cae: textColor = .tertiaryLabelColor
        case .cbe, .cce, .cdd: textColor = .quaternaryLabelColor
        }
        textView.textStorage!
            .setAttributedString(comment.text.styledAttributedString(textColor: textColor))
        creationLabel.stringValue = formatter.localizedString(
            for: comment.creation, relativeTo: Date())
        if Account.selectedAccount != nil {
            replyButton.isHidden = false
        } else {
            replyButton.isHidden = true
        }
    }

    @IBAction func executeAction(_ sender: NSButton) {
        guard objectValue != nil else { return }
        let comment = objectValue as! Comment
        let action: Action
        if sender == upvoteButton {
            action = upvoteAction!
        } else if sender == downvoteButton {
            action = downvoteAction!
        } else {
            fatalError()
        }
        delegate?.commentCellView(self, execute: action, for: comment)
    }

    @IBAction func reply(_ sender: NSButton) {
        let comment = objectValue as! Comment
        delegate?.commentCellView(self, replyTo: comment)
    }
}

extension NSUserInterfaceItemIdentifier {
    static let commentCell = NSUserInterfaceItemIdentifier("CommentCell")
}
