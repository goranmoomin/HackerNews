
import Cocoa

class SidebarCellView: NSTableCellView {

    override var objectValue: Any? {
        didSet {
            guard objectValue != nil else {
                return
            }
            let item = objectValue as! SidebarItem
            textField?.stringValue = item.description
        }
    }
}
