
import Foundation

extension NSString {

    func drawCentered(in rect: NSRect, withAttributes attributes: [NSAttributedString.Key : Any]) {
        let stringSize = size(withAttributes: attributes)
        let x = rect.origin.x + (rect.width - stringSize.width) / 2.0
        let y = rect.origin.y + (rect.height - stringSize.height) / 2.0
        let point = NSPoint(x: x, y: y)
        draw(at: point, withAttributes: attributes)
    }
}
