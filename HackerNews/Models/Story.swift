
import Foundation

@objc class Story: NSObject, Decodable, Itemable, Storyable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time = "created_at_i"
        case author
        case score = "points"
        case title
        case text
        case url
        case commentItems = "children"
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    // Some stories don't have a URL
    var url: URL?
    // but have text.
    var text: String?

    lazy var comments: [Comment] = commentItems?.compactMap { $0.comment } ?? []
    var commentCount: Int {
        comments.reduce(into: 0) { $0 += $1.commentCount }
    }
    var commentItems: [Item]?
}
