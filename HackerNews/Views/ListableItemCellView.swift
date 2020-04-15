
import Cocoa
import HNAPI

protocol ListableItemCellViewDelegate {
    func open(item: TopLevelItem)
}

class ListableItemCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorGroup: NSStackView!
    @IBOutlet var authorButton: NSButton!
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var scoreGroup: NSStackView!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var commentCountGroup: NSStackView!
    @IBOutlet var commentCountLabel: NSTextField!
    @IBOutlet var ageGroup: NSStackView!
    @IBOutlet var ageLabel: NSTextField!
    @IBOutlet var urlButton: NSButton!

    // MARK: - Properties

    // Data source of StoryCellView
    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var item: TopLevelItem? {
        objectValue as? TopLevelItem
    }

    let formatter = RelativeDateTimeFormatter()

    // MARK: - Delegate

    var delegate: ListableItemCellViewDelegate?

    // MARK: - Methods

    func updateInterface() {
        guard let item = item else {
            return
        }
        switch item {
        case let .story(story):
            authorButton.title = story.author
            authorGroup.isHidden = false
            titleLabel.stringValue = story.title
            switch story.content {
            case .text:
                urlButton.isHidden = true
            case let .url(url):
                urlButton.title = url.host ?? ""
                urlButton.isHidden = false
            }
            scoreLabel.stringValue = "\(story.points)"
            scoreGroup.isHidden = false
            ageLabel.stringValue = formatter.localizedString(for: story.creation, relativeTo: Date())
            commentCountLabel.stringValue = "\(story.commentCount)"
            commentCountGroup.isHidden = false
        case let .job(job):
            authorGroup.isHidden = true
            titleLabel.stringValue = job.title
            switch job.content {
            case .text:
                urlButton.isHidden = true
            case let .url(url):
                urlButton.title = url.host ?? ""
                urlButton.isHidden = false
            }
            scoreLabel.isHidden = true
            ageLabel.stringValue = formatter.localizedString(for: job.creation, relativeTo: Date())
            commentCountGroup.isHidden = false
        }
    }

    @IBAction func openItem(_ sender: NSButton) {
        guard let item = item else {
            return
        }
        delegate?.open(item: item)
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {
    static let listableItemCellView = NSUserInterfaceItemIdentifier("ListableItemCellView")
}
