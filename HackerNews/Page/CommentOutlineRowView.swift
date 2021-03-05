
import Cocoa

class CommentOutlineRowView: NSTableRowView {

    var level: Int
    var isExpandable: Bool
    var indentationPerLevel: CGFloat


    init(withLevel level: Int, isExpandable: Bool, indentationPerLevel: CGFloat) {
        self.level = level
        self.isExpandable = isExpandable
        self.indentationPerLevel = indentationPerLevel
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isMouseHovering = false {
        didSet {
            setNeedsDisplay(NSRect(x: 0, y: 0, width: CGFloat(level + 1) * indentationPerLevel, height: bounds.height))
        }
    }
    lazy var trackingArea = makeTrackingArea()

    override func updateTrackingAreas() {
        removeTrackingArea(trackingArea)
        trackingArea = makeTrackingArea()
        let mouseLocation = convert(window!.mouseLocationOutsideOfEventStream, from: nil)
        if bounds.contains(mouseLocation) {
            mouseEntered(with: NSEvent())
        } else {
            mouseExited(with: NSEvent())
        }
        addTrackingArea(trackingArea)
        super.updateTrackingAreas()
    }

    func makeTrackingArea() -> NSTrackingArea {
        NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isMouseHovering = true
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isMouseHovering = false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isMouseHovering {
            NSColor.systemGray.setFill()
            let minX = dirtyRect.minX + CGFloat(level + 1) * indentationPerLevel
            let minY = dirtyRect.minY + (isExpandable ? 22 : 2)
            let height = dirtyRect.height - (isExpandable ? 24 : 4)
            let barRect = NSRect(x: minX, y: minY, width: 4, height: height)
            let barPath = NSBezierPath(roundedRect: barRect, xRadius: 2, yRadius: 2)
            barPath.fill()
        }
    }
}
