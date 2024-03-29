import Carbon
import Cocoa

class CommentOutlineView: NSOutlineView {

    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_LeftArrow || event.keyCode == kVK_RightArrow {
            // send -moveLeft: & -moveRight: up the responder chain
            interpretKeyEvents([event])
        } else {
            super.keyDown(with: event)
        }
    }

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        let rowRect = rect(ofRow: row)
        let frame = super.frameOfOutlineCell(atRow: row)
        return NSRect(x: frame.minX, y: rowRect.minY + 2, width: frame.width, height: 18)
    }
}
