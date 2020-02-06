
import Foundation

class LegacyPoll: Decodable, LegacyItemable, LegacyStoryable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case authorName = "by"
        case score
        case title
        case text
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var authorName: String
    var author: LegacyUser?
    var score: Int
    var title: String
    var text: String
    var availableActions: Set<LegacyAction> = []
}
