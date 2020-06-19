
import Cocoa
import HNAPI
import Atributika

protocol CommentCellViewDelegate {
    func expandComments(for comment: Comment)
    func collapseComments(for comment: Comment)
    func isCommentsHidden(for comment: Comment) -> Bool
}

class CommentCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorButton: NSButton!
    @IBOutlet var ageLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var toggleButton: NSButton!
    @IBOutlet var toggleCountLabel: NSTextField!
    @IBOutlet var actionView: ActionView!

    // MARK: - Properties

    // Data source of StoryCellView
    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var comment: Comment? {
        objectValue as? Comment
    }

    var isCommentHidden: Bool = false {
        didSet {
            guard let comment = comment else {
                return
            }
            if isCommentHidden {
                delegate?.collapseComments(for: comment)
            } else {
                delegate?.expandComments(for: comment)
            }
        }
    }

    let formatter = RelativeDateTimeFormatter()

    // MARK: - Delegate

    var delegate: CommentCellViewDelegate?

    // MARK: - IBAction

    @IBAction func toggleComment(_ sender: NSButton) {
        isCommentHidden = !isCommentHidden
        updateInterface()
    }

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        actionView.delegate = self
    }

    // MARK: - Methods

    func commentText() -> NSAttributedString {
        guard let comment = comment else {
            return NSAttributedString()
        }
        textLabel.allowsEditingTextAttributes = true
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        let systemFontSize = NSFont.systemFontSize(for: .regular)
        let all = Style
            .font(.systemFont(ofSize: systemFontSize))
            .foregroundColor(.textColor)
            .paragraphStyle(paragraphStyle)
        let a = Style("a")
        let i = Style("i")
            .font(.italicSystemFont(ofSize: systemFontSize))
        let pre = Style("pre")
            .font(.monospacedSystemFont(ofSize: systemFontSize, weight: .regular))
        let transformers = [
            TagTransformer(tagName: "p", tagType: .start, replaceValue: "\n"),
            .brTransformer
        ]
        func tuner(style: Style, tag: Tag) -> Style {
            if tag.name == a.name, let href = tag.attributes["href"], let url = URL(string: href) {
                return style.link(url)
            }
            return style
        }
        return comment.text
            .style(tags: a, i, pre, transformers: transformers, tuner: tuner(style:tag:))
            .styleAll(all).attributedString
    }

    func updateInterface() {
        guard let comment = comment else {
            return
        }
        authorButton.title = comment.author
        ageLabel.stringValue = formatter.localizedString(for: comment.creation, relativeTo: Date())
        // TODO: Get actions from Page instance
        actionView.actions = []
        if isCommentHidden {
            toggleCountLabel.stringValue = "\(comment.commentCount) comments hidden"
            textLabel.isHidden = true
        } else {
            toggleCountLabel.stringValue = ""
            textLabel.attributedStringValue = commentText()
            textLabel.isHidden = false
        }
    }
}

extension CommentCellView: ActionViewDelegateProtocol {
    func execute(_ action: Action, token: Token) {
        // TODO: How to get Page instance?
        APIClient.shared.execute(action: action, token: token) { result in
            guard case .success = result else {
                // TODO: Error handling
                return
            }
        }
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {
    static let commentCellView = NSUserInterfaceItemIdentifier("CommentCellView")
}
