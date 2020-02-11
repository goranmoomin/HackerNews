
import Cocoa

class ItemRowView: NSTableRowView {

    // MARK: - Overrides

    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.emphasizedBackgroundColor.setFill()
        dirtyRect.fill()
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {
    static let itemRowView = NSUserInterfaceItemIdentifier("ItemRowView")
}
