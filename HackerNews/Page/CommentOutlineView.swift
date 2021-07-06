import Cocoa

class CommentOutlineView: NSOutlineView {

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        let rowRect = rect(ofRow: row)
        let frame = super.frameOfOutlineCell(atRow: row)
        return NSRect(x: frame.minX, y: rowRect.minY + 2, width: frame.width, height: 18)
    }
}
