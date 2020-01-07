
import Foundation

@objc class Job: NSObject, Decodable, Itemable, Storyable {

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case score
        case title
        case text
        case url
    }

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    // Some jobs don't have a URL
    var url: URL?
    // but have text.
    var text: String?
}
