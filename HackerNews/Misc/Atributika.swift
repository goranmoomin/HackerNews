
import Foundation
import Atributika

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
