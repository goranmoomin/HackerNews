
import Foundation

class Poll: Decodable, Itemable, Storyable {

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
    var author: User?
    var score: Int
    var title: String
    var text: String
}
