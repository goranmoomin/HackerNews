
import Cocoa

class DisclosureTrianglelessOutlineView: NSOutlineView {

    // MARK: - Overrides

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        .zero
    }

    override func frameOfCell(atColumn column: Int, row: Int) -> NSRect {
        var frame = super.frameOfCell(atColumn: column, row: row)

        frame.origin.x -= indentationPerLevel
        frame.size.width += indentationPerLevel

        return frame
    }
}
