
import Cocoa

protocol CommentCellViewDelegate {

    func formattedAuthor(for comment: LegacyComment?) -> String
    func formattedDate(for comment: LegacyComment?) -> String
    func formattedText(for comment: LegacyComment?) -> String
    func isToggleHidden(for comment: LegacyComment?) -> Bool
    func isToggleExpanded(for comment: LegacyComment?) -> Bool
    func formattedToggleCount(for comment: LegacyComment?) -> String

    func toggle(_ comment: LegacyComment?)
    func displayPopup(for comment: LegacyComment?, relativeTo rect: NSRect, of view: CommentCellView)
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

    var comment: LegacyComment? {
        objectValue as? LegacyComment
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
