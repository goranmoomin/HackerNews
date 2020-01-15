
import Foundation

@objc class Story: NSObject, Decodable, Itemable, Storyable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case score
        case title
        case text
        case rawURL = "url"
        case commentIds = "kids"
        case commentCount = "descendants"
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    // Some stories don't have a URL or an empty string
    var rawURL: String?
    lazy var url: URL? = URL(string: rawURL ?? "")
    // but have text.
    var text: String?
    var commentIds: [Int]?
    var comments: [Comment] = []
    var commentCount: Int
}
