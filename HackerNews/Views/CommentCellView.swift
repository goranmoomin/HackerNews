
import Cocoa
import HackerNewsAPI
import Atributika

class CommentCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorButton: NSButton!
    @IBOutlet var ageLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
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

    // MARK: - Methods

    func updateTextLabel() {
        guard let comment = comment else {
            return
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
        textLabel.attributedStringValue = comment.text
            .style(tags: a, i, pre, transformers: transformers, tuner: tuner(style:tag:))
            .styleAll(all).attributedString
    }

    func updateInterface() {
        guard let comment = comment else {
            return
        }
        authorButton.title = comment.authorName
        ageLabel.stringValue = comment.ageDescription
        actionView.actions = comment.actions
        updateTextLabel()
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {
    static let commentCellView = NSUserInterfaceItemIdentifier("CommentCellView")
}
