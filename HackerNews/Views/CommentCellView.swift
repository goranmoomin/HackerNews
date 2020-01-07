
import Cocoa

@objc protocol CommentCellViewDelegate {
    func commentCellView(_ commentCellView: CommentCellView, toggleButtonWillBeClickedForComment comment: Comment?)
    func commentCellView(_ commentCellView: CommentCellView, isCommentExpandable comment: Comment?) -> Bool
    func commentCellView(_ commentCellView: CommentCellView, isCommentExpanded comment: Comment?) -> Bool
}

class CommentCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var commentLabel: NSTextField!
    @IBOutlet var toggleButton: NSButton!

    // MARK: - Delegate

    @IBOutlet var delegate: CommentCellViewDelegate?

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

    // MARK: - IBActions

    @IBAction func toggleButton(_ sender: NSButton) {
        delegate?.commentCellView(self, toggleButtonWillBeClickedForComment: comment)
    }

    // MARK: - Methods

    func updateInterface() {
        guard let comment = comment else {
            commentLabel.stringValue = ""
            authorLabel.stringValue = ""
            return
        }
        let textData = comment.text.data(using: .utf16) ?? Data()
        let attributedString = NSAttributedString(html: textData, documentAttributes: nil)
        commentLabel.stringValue = attributedString?.string ?? ""
        authorLabel.stringValue = comment.author
        let isExpandable = delegate?.commentCellView(self, isCommentExpandable: comment) ?? false
        let isExpanded = delegate?.commentCellView(self, isCommentExpanded: comment) ?? false
        toggleButton.isHidden = !isExpandable
        toggleButton.state = isExpanded ? .off : .on
    }
}
