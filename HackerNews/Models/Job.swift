
import Foundation

class Job: Decodable, Itemable, Storyable {

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case authorName = "by"
        case score
        case title
        case text
        case rawURL = "url"
    }

    // MARK: - Properties

    var id: Int
    var time: Date
    var authorName: String
    var author: User?
    var score: Int
    var title: String
    // Some jobs don't have a URL or an empty string
    var rawURL: String?
    lazy var url: URL? = URL(string: rawURL ?? "")
    // but have text.
    var text: String?
    var availableActions: Set<Action> = []
}
