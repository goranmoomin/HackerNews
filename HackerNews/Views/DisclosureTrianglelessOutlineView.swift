
import Cocoa

class DisclosureTrianglelessOutlineView: NSOutlineView {

    // MARK: - Overrides

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        .zero
    }
}
