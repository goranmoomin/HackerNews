
import Cocoa

protocol CommentCellViewDelegate {

    func formattedAuthor(for comment: Comment?) -> String
    func formattedDate(for comment: Comment?) -> String
    func formattedText(for comment: Comment?) -> String
    func isToggleHidden(for comment: Comment?) -> Bool
    func isToggleExpanded(for comment: Comment?) -> Bool
    func formattedToggleCount(for comment: Comment?) -> String

    func toggle(_ comment: Comment?)
    func displayPopup(for comment: Comment?, relativeTo rect: NSRect, of view: CommentCellView)
}

class CommentCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorButton: NSButton!
    @IBOutlet var dateLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var toggleButton: NSButton!
    @IBOutlet var toggleCountLabel: NSTextField!
    @IBOutlet var actionView: ActionView!

    // MARK: - Delegate

    var delegate: CommentCellViewDelegate?

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

    @IBAction func displayPopover(_ sender: NSButton) {
        guard let delegate = delegate else {
            return
        }
        delegate.displayPopup(for: comment, relativeTo: sender.frame, of: self)
    }

    @IBAction func toggleButton(_ sender: NSButton) {
        delegate?.toggle(comment)
        updateInterface()
    }

    // MARK: - Methods

    func updateInterface() {
        guard let delegate = delegate else {
            return
        }
        textLabel.stringValue = delegate.formattedText(for: comment)
        authorButton.title = delegate.formattedAuthor(for: comment)
        dateLabel.stringValue = delegate.formattedDate(for: comment)
        toggleButton.isHidden = delegate.isToggleHidden(for: comment)
        toggleButton.state = delegate.isToggleExpanded(for: comment) ? .off : .on
        toggleCountLabel.stringValue = delegate.formattedToggleCount(for: comment)
        actionView.actions = comment?.availableActions ?? []
    }
}
