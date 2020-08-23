
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        let systemFontSize = NSFont.systemFontSize(for: .regular)
        let textColor: NSColor
        switch comment.color {
        case .c00: textColor = .labelColor
        case .c5a, .c73, .c82: textColor = .secondaryLabelColor
        case .c88, .c9c, .cae: textColor = .tertiaryLabelColor
        case .cbe, .cce, .cdd: textColor = .quaternaryLabelColor
        }
        let all = Style
            .font(.systemFont(ofSize: systemFontSize))
            .foregroundColor(textColor)
            .paragraphStyle(paragraphStyle)
        let a = Style("a")
        let i = Style("i")
            .font(.italicSystemFont(ofSize: systemFontSize))
        let pre = Style("pre")
            .font(.monospacedSystemFont(ofSize: systemFontSize, weight: .regular))
        let transformers: [TagTransformer] = [
            .pTransformer(),
            .brTransformer
        ]
        func tuner(style: Style, tag: Tag) -> Style {
            if tag.name == a.name, let href = tag.attributes["href"], let url = URL(string: href) {
                return style.link(url)
            }
            return style
        }
        textLabel.attributedStringValue = comment.text.style(tags: a, i, pre, transformers: transformers, tuner: tuner(style:tag:))
            .styleAll(all).attributedString
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
