
import Foundation

@objc class Poll: NSObject, Decodable, Itemable, Storyable {

    enum CodingKeys: String, CodingKey {
        case id
        case time = "created_at_i"
        case author
        case score = "points"
        case title
        case text
    }

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    var text: String
}
