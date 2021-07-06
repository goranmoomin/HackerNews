import Cocoa
import HNAPI

class AccountCellView: NSTableCellView {

    override var objectValue: Any? {
        didSet {
            guard objectValue != nil else { return }
            textField?.stringValue = objectValue as! String
        }
    }
}
