
import Cocoa

protocol StoryCellViewDelegate {

    func formattedAuthor(for story: LegacyStoryable?) -> String
    func formattedTitle(for story: LegacyStoryable?) -> String
    func formattedScore(for story: LegacyStoryable?) -> String
    func formattedCommentCount(for story: LegacyStoryable?) -> String
    func isURLHidden(for story: LegacyStoryable?) -> Bool
    func formattedURL(for story: LegacyStoryable?) -> String
    func formattedDate(for story: LegacyStoryable?) -> String

    func openURL(for story: LegacyStoryable?)
    func displayPopup(for story: LegacyStoryable?, relativeTo rect: NSRect, of view: StoryCellView)
}

class StoryCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorButton: NSButton!
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var commentCountLabel: NSTextField!
    @IBOutlet var dateLabel: NSTextField!
    @IBOutlet var urlButton: NSButton!

    // MARK: - Delegate

    var delegate: StoryCellViewDelegate?

    // MARK: - Properties

    // Data source of StoryCellView
    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var story: LegacyStoryable? {
        objectValue as? LegacyStoryable
    }

    // MARK: - IBActions

    @IBAction func openURL(_ sender: NSButton) {
        delegate?.openURL(for: story)
    }

    @IBAction func displayPopup(_ sender: NSButton) {
        delegate?.displayPopup(for: story, relativeTo: sender.frame, of: self)
    }

    // MARK: - Methods

    func updateInterface() {
        guard let delegate = delegate else {
            return
        }
        authorButton.title = delegate.formattedAuthor(for: story)
        titleLabel.stringValue = delegate.formattedTitle(for: story)
        scoreLabel.stringValue = delegate.formattedScore(for: story)
        commentCountLabel.stringValue = delegate.formattedCommentCount(for: story)
        urlButton.isHidden = delegate.isURLHidden(for: story)
        urlButton.title = delegate.formattedURL(for: story)
        dateLabel.stringValue = delegate.formattedDate(for: story)
    }
}
