import Atributika
import Cocoa
import SwiftSoup

extension TagTransformer {
    static func pTransformer() -> TagTransformer {
        var isStart = true
        let transformer = TagTransformer(tagName: "p", tagType: .start) { _ in
            if isStart {
                isStart = false
                return ""
            } else {
                return "\n"
            }
        }
        return transformer
    }
}

extension String {
    func styledAttributedString(textColor: Color) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        let systemFontSize = NSFont.systemFontSize(for: .regular)
        let all = Style.font(.systemFont(ofSize: systemFontSize)).foregroundColor(textColor)
            .paragraphStyle(paragraphStyle)
        let a = Style("a")
        let i = Style("i").font(.italicSystemFont(ofSize: systemFontSize))
        let pre = Style("pre").font(.monospacedSystemFont(ofSize: systemFontSize, weight: .regular))
        let transformers: [TagTransformer] = [.pTransformer(), .brTransformer]
        func tuner(style: Style, tag: Atributika.Tag) -> Style {
            if tag.name == a.name, let href = tag.attributes["href"] {
                // NOTE: The Algolia API returns HTML with escaped href attributes, hence this hack.
                if let url = URL(string: href) ?? URL(string: try! Entities.unescape(href)) {
                    return style.link(url)
                }
            }
            return style
        }
        return self.style(tags: a, i, pre, transformers: transformers, tuner: tuner(style:tag:))
            .styleAll(all).attributedString
    }
}
