
import Cocoa

class StoryRowView: NSTableRowView {

    // MARK: - Overrides

    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.emphasizedBackgroundColor.setFill()
        dirtyRect.fill()
    }
}
