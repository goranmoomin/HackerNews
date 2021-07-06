import Cocoa

extension NSFont {
    class func italicSystemFont(ofSize size: CGFloat) -> NSFont {
        let fontManager = NSFontManager.shared
        let italicSystemFont = fontManager.convert(
            .systemFont(ofSize: size), toHaveTrait: .italicFontMask)
        return italicSystemFont
    }
}
