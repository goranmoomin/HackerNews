
import Foundation

@objc class Poll: NSObject, Decodable, Itemable, Storyable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case score
        case title
        case text
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    var text: String
}
