
import Foundation

class Poll: Decodable, Itemable, Storyable {

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case score
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
