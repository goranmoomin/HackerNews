
import Cocoa

class StoryCellView: NSTableCellView, LoadableView {

    // MARK: - IBOutlets

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var commentCountLabel: NSTextField!

    // MARK: - Properties

    // Data source of StoryTableCellView
    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var story: Storyable? {
        objectValue as? Storyable
    }

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

    // MARK: - Init

    var mainView: NSView?

    init() {
        super.init(frame: .zero)
        loadFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
}
