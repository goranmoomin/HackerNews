
import Cocoa
import HackerNewsAPI

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

    var item: ListableItem? {
        objectValue as? ListableItem
    }

    // MARK: - Methods

    func updateInterface() {
        guard let item = item else {
            return
        }
        if let authorName = item.authorName {
            authorButton.title = authorName
            authorGroup.isHidden = false
        } else {
            authorGroup.isHidden = true
        }
        titleLabel.stringValue = item.title
        if let score = item.score {
            scoreLabel.stringValue = String(score)
            scoreGroup.isHidden = false
        } else {
            scoreGroup.isHidden = true
        }
        ageLabel.stringValue = item.ageDescription
        if let commentCount = item.commentCount {
            commentCountLabel.stringValue = String(commentCount)
            commentCountGroup.isHidden = false
        } else {
            commentCountGroup.isHidden = true
        }
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {
    static let listableItemCellView = NSUserInterfaceItemIdentifier("ListableItemCellView")
}
