
import Cocoa

class EmphasizableTextFieldCell: NSTextFieldCell {

    // MARK: - Properties

    var emphasizedTextColor: NSColor? = .emphasizedTextColor
    lazy var normalTextColor: NSColor? = textColor

    // MARK: - Overrides

    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            toggleTextColor()
        }
    }

    // MARK: - Methods

    func toggleTextColor() {
        if backgroundStyle == .emphasized {
            textColor = emphasizedTextColor
        } else {
            textColor = normalTextColor
        }
    }
}
