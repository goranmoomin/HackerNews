
import Cocoa

class CommentOutlineView: NSOutlineView {

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        let frame = super.frameOfOutlineCell(atRow: row)
        return NSRect(x: frame.minX, y: frame.minY + 1, width: frame.width, height: 18)
    }
}
