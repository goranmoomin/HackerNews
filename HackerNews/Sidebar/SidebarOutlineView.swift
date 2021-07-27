import Carbon
import Cocoa

class SidebarOutlineView: NSOutlineView {

    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_LeftArrow || event.keyCode == kVK_RightArrow {
            // send -moveLeft: & -moveRight: up the responder chain
            interpretKeyEvents([event])
        } else {
            super.keyDown(with: event)
        }
    }
}
