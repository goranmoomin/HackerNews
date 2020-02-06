
import Foundation

class LegacyPollOption: Decodable, LegacyItemable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case authorName = "by"
        case score
        case text
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var authorName: String
    var author: LegacyUser?
    var score: Int
    var text: String
    var availableActions: Set<LegacyAction> = []
}
