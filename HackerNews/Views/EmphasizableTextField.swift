
import Cocoa

class EmphasizableTextField: NSTextField {

    // MARK: - Properties

    var emphasizedTextColor: NSColor = .emphasizedTextColor
    lazy var normalTextColor: NSColor = textColor ?? .labelColor

    @objc var backgroundStyle: NSView.BackgroundStyle = .normal {
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
