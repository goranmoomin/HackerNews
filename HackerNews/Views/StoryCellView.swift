
import Cocoa

@objc protocol StoryCellViewDelegate {
    func storyCellView(_ storyCellView: StoryCellView, urlButtonWillBeClickedForStory story: Storyable?)
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

    @IBAction func urlButton(_ sender: NSButton) {
        delegate?.storyCellView(self, urlButtonWillBeClickedForStory: story)
    }

    // MARK: - Methods

    func updateInterface() {
        guard let story = story else {
            return
        }
        titleLabel.stringValue = story.title
        scoreLabel.stringValue = "\(story.score)"

        if let story = story as? Story {
            commentCountLabel.stringValue = "\(story.commentCount)"
            if let url = story.url {
                urlButton.title = "\(url.host ?? url.absoluteString)"
            } else {
                urlButton.isHidden = true
            }
        } else {
            commentCountLabel.stringValue = ""
            urlButton.isHidden = true
        }
    }
}
