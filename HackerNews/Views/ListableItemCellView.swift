
import Cocoa
import HackerNewsAPI

class ListableItemCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var authorIcon: NSTextField!
    @IBOutlet var authorButton: NSButton!
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var scoreLabel: NSTextField!
    @IBOutlet var commentCountLabel: NSTextField!
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
        authorButton.title = item.authorName ?? ""
        titleLabel.stringValue = item.title
        scoreLabel.stringValue = String(item.score ?? 0)
        ageLabel.stringValue = item.ageDescription
        if let commentCount = item.commentCount {
            commentCountLabel.stringValue = String(commentCount)
        } else {
            commentCountLabel.stringValue = ""
        }
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {
    static let listableItemCellView = NSUserInterfaceItemIdentifier("ListableItemCellView")
}
