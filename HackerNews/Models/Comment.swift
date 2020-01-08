
import Foundation
import PromiseKit

@objc class Comment: NSObject, Decodable, Itemable {

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case text
        case commentIds = "kids"
    }

    var id: Int
    var time: Date
    var author: String
    var text: String
    var commentIds: [Int]?
    var comments: [Comment] = []
}
