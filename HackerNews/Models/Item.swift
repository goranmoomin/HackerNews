
import Foundation

protocol Itemable: class {
    var id: Int { get }
    var time: Date { get }
    var author: User? { get set }
    var authorName: String { get }
    var availableActions: Set<Action> { get set }
}

protocol Storyable: Itemable {
    var score: Int { get }
    var title: String { get }
}

enum Item {
    case job(Job)
    case story(Story)
    case comment(Comment)
    case poll(Poll)
    case pollOption(PollOption)
    case deletedItem
}

extension Item {

    // MARK: - Properties

    var item: Itemable? {
        switch self {
        case .job(let job):
            return job
        case .story(let story):
            return story
        case .comment(let comment):
            return comment
        case .poll(let poll):
            return poll
        case .pollOption(let pollOption):
            return pollOption
        case .deletedItem:
            return nil
        }
    }

    var story: Storyable? {
        item as? Storyable
    }

    var comment: Comment? {
        item as? Comment
    }
}

// MARK: - Decodable

extension Item: Decodable {

    enum CodingKeys: CodingKey {
        case type
        case deleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isDeleted = (try? container.decode(Bool.self, forKey: .deleted)) ?? false
        guard !isDeleted else {
            self = .deletedItem
            return
        }

        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "job":
            self = .job(try decoder.singleValueContainer().decode(Job.self))
        case "story":
            self = .story(try decoder.singleValueContainer().decode(Story.self))
        case "comment":
            self = .comment(try decoder.singleValueContainer().decode(Comment.self))
        case "poll":
            self = .poll(try decoder.singleValueContainer().decode(Poll.self))
        case "pollopt":
            self = .pollOption(try decoder.singleValueContainer().decode(PollOption.self))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: """
                The value of key "type" has an incorrect value of \(type).
                It should be one of: "job", "story", "comment", "poll", or "pollopt".
                """))
        }
    }
}
