
import Cocoa

class EmphasizableTextFieldCell: NSTextFieldCell {

    var emphasizedTextColor: NSColor? = .emphasizedTextColor
    lazy var normalTextColor: NSColor? = textColor

    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            toggleTextColor()
        }
    }

    func toggleTextColor() {
        if backgroundStyle == .emphasized {
            textColor = emphasizedTextColor
        } else {
            textColor = normalTextColor
        }
    }
}
