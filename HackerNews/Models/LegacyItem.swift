
import Foundation

protocol LegacyItemable: class {
    var id: Int { get }
    var time: Date { get }
    var author: LegacyUser? { get set }
    var authorName: String { get }
    var availableActions: Set<LegacyAction> { get set }
}

protocol LegacyStoryable: LegacyItemable {
    var score: Int { get }
    var title: String { get }
}

enum LegacyItem {
    case job(LegacyJob)
    case story(LegacyStory)
    case comment(LegacyComment)
    case poll(LegacyPoll)
    case pollOption(LegacyPollOption)
    case deletedItem
}

extension LegacyItem {

    // MARK: - Properties

    var item: LegacyItemable? {
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

    var story: LegacyStoryable? {
        item as? LegacyStoryable
    }

    var comment: LegacyComment? {
        item as? LegacyComment
    }
}

// MARK: - Decodable

extension LegacyItem: Decodable {

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
            self = .job(try decoder.singleValueContainer().decode(LegacyJob.self))
        case "story":
            self = .story(try decoder.singleValueContainer().decode(LegacyStory.self))
        case "comment":
            self = .comment(try decoder.singleValueContainer().decode(LegacyComment.self))
        case "poll":
            self = .poll(try decoder.singleValueContainer().decode(LegacyPoll.self))
        case "pollopt":
            self = .pollOption(try decoder.singleValueContainer().decode(LegacyPollOption.self))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: """
                The value of key "type" has an incorrect value of \(type).
                It should be one of: "job", "story", "comment", "poll", or "pollopt".
                """))
        }
    }
}
