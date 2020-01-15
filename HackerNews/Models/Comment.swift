
import Foundation

@objc class Comment: NSObject, Decodable, Itemable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case text
        case commentIds = "kids"
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var author: String
    var text: String
    var commentIds: [Int]?
    var comments: [Comment] = []
    var commentCount: Int {
        comments.reduce(into: 1) { $0 += $1.commentCount }
    }
}
