
import Foundation
import PromiseKit

class Comment: NSObject, Decodable, Itemable {

    enum CodingKeys: String, CodingKey {
        case id
        case time
        case author = "by"
        case text
        case commentIds = "kids"
    }

    var id: Int
    var time: Date
    var author: String
    var text: String
    var commentIds: [Int]?
    var comments: [Comment] = []
    var commentCount: Int {
        comments.map { $0.commentCount }.reduce(0, +) + 1
    }

    func loadComments() -> Promise<Comment> {
        let promises = commentIds?.map { id in HackerNewsAPI.firebaseItem(id: id) } ?? []
        let promise = firstly {
            when(fulfilled: promises)
        }.compactMapValues { item in
            item.comment
        }.thenMap { comment in
            comment.loadComments()
        }.map { comments -> Comment in
            self.comments = comments
            return self
        }
        return promise
    }
}
