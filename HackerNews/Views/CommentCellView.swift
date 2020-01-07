
import Cocoa

@objc protocol CommentCellViewDelegate {

    func formattedAuthor(for comment: Comment?) -> String
    func formattedText(for comment: Comment?) -> String
    func isToggleHidden(for comment: Comment?) -> Bool
    func isToggleExpanded(for comment: Comment?) -> Bool

    func toggle(_ comment: Comment?)
}

class CommentCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
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
        delegate?.toggle(comment)
    }

    // MARK: - Methods

    func updateInterface() {
        guard let delegate = delegate else {
            return
        }
        textLabel.stringValue = delegate.formattedText(for: comment)
        authorLabel.stringValue = delegate.formattedAuthor(for: comment)
        toggleButton.isHidden = delegate.isToggleHidden(for: comment)
        toggleButton.state = delegate.isToggleExpanded(for: comment) ? .off : .on
    }
}
