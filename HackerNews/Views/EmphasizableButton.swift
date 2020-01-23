
import Cocoa

class EmphasizableButton: NSButton {

    // MARK: - Properties

    var emphasizedTextColor: NSColor = .emphasizedTextColor
    var normalTextColor: NSColor = .controlTextColor

    @objc var backgroundStyle: NSView.BackgroundStyle = .normal {
        didSet {
            toggleTextColor()
        }
    }

    // MARK: - Methods

    func toggleTextColor() {
        let mutableAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        let mutableAttributedTitleRange = NSRange(location: 0, length: mutableAttributedTitle.length)

        if backgroundStyle == .emphasized {
            mutableAttributedTitle.addAttribute(.foregroundColor, value: emphasizedTextColor, range: mutableAttributedTitleRange)
        } else {
            mutableAttributedTitle.addAttribute(.foregroundColor, value: normalTextColor, range: mutableAttributedTitleRange)
        }
        attributedTitle = mutableAttributedTitle
    }
}
