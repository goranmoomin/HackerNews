
import Foundation

struct User: Decodable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case creation = "created"
        case selfDescription = "about"
        case name = "id"
        case karma
    }

    // MARK: - Properties

    var creation: Date
    var selfDescription: String?
    var name: String
    var karma: Int
}
