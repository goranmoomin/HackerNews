
import Cocoa

class StoryCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var commentCountLabel: NSTextField!

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

    // MARK: - Methods

    func updateInterface() {
        guard let story = story else {
            return
        }
        titleLabel.stringValue = story.title
        scoreLabel.stringValue = "\(story.score) points"

        if let story = story as? Story {
            commentCountLabel.stringValue = "\(story.commentCount) comments"
        } else {
            commentCountLabel.stringValue = ""
        }
    }
}
