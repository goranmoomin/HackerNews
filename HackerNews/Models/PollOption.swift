
import Foundation

@objc class PollOption: NSObject, Decodable, Itemable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time = "created_at_i"
        case author
        case score = "points"
        case text
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var text: String
}
