
import Cocoa

class CommentOutlineView: NSOutlineView {

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        var frame = super.frameOfOutlineCell(atRow: row)
        frame.size.height = 19.0
        return frame
    }
}
