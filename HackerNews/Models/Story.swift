
import Foundation
import PromiseKit

class Story: NSObject, Decodable, Itemable, Storyable {

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case score
        case title
        case text
        case url
        case commentIds = "kids"
    }

    var id: Int
    var time: Date
    var author: String
    var score: Int
    var title: String
    // Some stories don't have a URL
    var url: URL?
    // but have text.
    var text: String?
    var commentIds: [Int]?
    var comments: [Comment] = []
    var commentCount: Int {
        comments.map { $0.commentCount }.reduce(0, +)
    }

    func loadComments() -> Promise<Void> {
        guard let commentIds = commentIds else {
            return .value
        }
        let promises = commentIds.map { id in HackerNewsAPI.item(id: id) }
        let promise = firstly {
            when(fulfilled: promises)
        }.compactMapValues { item in
            item.comment
        }.thenMap { comment in
            comment.loadComments()
        }.done { comments in
            self.comments = comments
        }
        return promise
    }
}
