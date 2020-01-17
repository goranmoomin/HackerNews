
import Cocoa

class SidebarCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var categoryLabel: NSTextField!

    // MARK: - Properties

    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var category: String? {
        objectValue as? String
    }

    // MARK: - Methods

    func updateInterface() {
        guard let category = category else {
            return
        }
        categoryLabel.stringValue = category
    }
}
