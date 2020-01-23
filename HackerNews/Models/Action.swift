
import Foundation

enum Action: Hashable {
    case upvote(URL)
    case downvote(URL)
}

extension Action {

    // MARK: - Properties

    var url: URL {
        switch self {
        case .upvote(let url):
            return url
        case .downvote(let url):
            return url
        }
    }

    var isUpvote: Bool {
        guard case .upvote = self else {
            return false
        }
        return true
    }

    var isDownvote: Bool {
        guard case .downvote = self else {
            return false
        }
        return true
    }
}
