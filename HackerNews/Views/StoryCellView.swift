
import Cocoa

@objc protocol StoryCellViewDelegate {

    func formattedTitle(for story: Storyable?) -> String
    func formattedScore(for story: Storyable?) -> String
    func formattedCommentCount(for story: Storyable?) -> String
    func isURLHidden(for story: Storyable?) -> Bool
    func formattedURL(for story: Storyable?) -> String

    func openURL(for story: Storyable?)
}

class StoryCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var commentCountLabel: NSTextField!
    @IBOutlet var urlButton: NSButton!

    // MARK: - Delegate

    @IBOutlet var delegate: StoryCellViewDelegate?

    // MARK: - Properties

    // Data source of StoryCellView
    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var story: Storyable? {
        objectValue as? Storyable
    }

    // MARK: - IBActions

    @IBAction func openURL(_ sender: NSButton) {
        delegate?.openURL(for: story)
    }

    // MARK: - Methods

    func updateInterface() {
        guard let delegate = delegate else {
            return
        }
        titleLabel.stringValue = delegate.formattedTitle(for: story)
        scoreLabel.stringValue = delegate.formattedScore(for: story)
        commentCountLabel.stringValue = delegate.formattedCommentCount(for: story)
        urlButton.isHidden = delegate.isURLHidden(for: story)
        urlButton.title = delegate.formattedURL(for: story)
    }
}
