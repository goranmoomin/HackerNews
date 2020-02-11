
import Cocoa

class SidebarCellView: NSTableCellView {

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
        textField?.stringValue = category
    }
}
