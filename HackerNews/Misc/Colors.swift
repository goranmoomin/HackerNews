
import Cocoa

extension NSColor {

    static var emphasizedTextColor = NSColor(calibratedRed: 21 / 255, green: 123 / 255, blue: 242 / 255, alpha: 1)
    static var emphasizedBackgroundColor = emphasizedTextColor.withAlphaComponent(0.1)
}
