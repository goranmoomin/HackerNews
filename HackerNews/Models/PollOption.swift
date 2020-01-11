
import Foundation

@objc class PollOption: NSObject, Decodable, Itemable {

    enum CodingKeys: String, CodingKey {
        case id
        case time = "created_at_i"
        case author
        case score = "points"
        case text
    }

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var text: String
}
