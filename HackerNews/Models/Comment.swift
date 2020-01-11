
import Foundation
import PromiseKit

@objc class Comment: NSObject, Decodable, Itemable {

    enum CodingKeys: String, CodingKey {
        case id
        case time = "created_at_i"
        case author
        case text
        case commentItems = "children"
    }

    var id: Int
    var time: Date
    var author: String
    var text: String

    lazy var comments: [Comment] = commentItems?.compactMap { $0.comment } ?? []
    var commentCount: Int {
        comments.reduce(into: 1) { $0 += $1.commentCount }
    }
    var commentItems: [Item]?
}
