
import Foundation

class LegacyComment: Decodable, LegacyItemable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case authorName = "by"
        case text
        case commentIds = "kids"
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var authorName: String
    var author: LegacyUser?
    var text: String
    var commentIds: [Int]?
    var comments: [LegacyComment] = []
    var commentCount: Int {
        comments.reduce(into: 1) { $0 += $1.commentCount }
    }
    var availableActions: Set<LegacyAction> = []
}
