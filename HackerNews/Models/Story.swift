
import Foundation
import PromiseKit

@objc class Story: NSObject, Decodable, Itemable, Storyable {

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case score
        case title
        case text
        case url
        case commentIds = "kids"
        case commentCount = "descendants"
    }

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    // Some stories don't have a URL
    var url: URL?
    // but have text.
    var text: String?
    var commentIds: [Int]?
    var comments: [Comment] = []
    var commentCount: Int
}
