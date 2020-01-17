
import Foundation

@objc class PollOption: NSObject, Decodable, Itemable {

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
    var author: User?
    var score: Int
    var text: String
}
