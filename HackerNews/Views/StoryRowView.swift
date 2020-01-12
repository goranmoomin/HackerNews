
import Cocoa

class StoryRowView: NSTableRowView {

    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.emphasizedBackgroundColor.setFill()
        dirtyRect.fill()
    }
}
