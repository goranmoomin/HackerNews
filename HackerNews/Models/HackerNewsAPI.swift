
import Foundation
import PromiseKit

class HackerNewsAPI {
    enum HNError: Error {
        case statusCode
        case unexpectedData
    }

    static let urlSession = URLSession.shared
    static let base = URL(string: "https://hacker-news.firebaseio.com/v0/")!

    static func item(id: Int) -> Promise<Item> {
        let request = URLRequest(url: base.appendingPathComponent("item/\(id).json"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let promise = firstly {
            urlSession.dataTask(.promise, with: request)
        }.map { (data, _) in
            try decoder.decode(Item.self, from: data)
        }
        return promise
    }

    static func topStories(count: Int = 500) -> Promise<[Storyable]> {
        let request = URLRequest(url: base.appendingPathComponent("topstories.json"))
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode([Int].self, from: data)
        }.map { ids in
            Array(ids.prefix(count))
        }.thenMap { id in
            item(id: id)
        }.mapValues { item in
            item.story!
        }
        return promise
    }

    static func newStories(count: Int = 500) -> Promise<[Storyable]> {
        let request = URLRequest(url: base.appendingPathComponent("newstories.json"))
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode([Int].self, from: data)
        }.map { ids in
            Array(ids.prefix(count))
        }.thenMap { id in
            item(id: id)
        }.mapValues { item in
            item.story!
        }
        return promise
    }

    static func bestStories(count: Int = 500) -> Promise<[Storyable]> {
        let request = URLRequest(url: base.appendingPathComponent("beststories.json"))
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode([Int].self, from: data)
        }.map { ids in
            Array(ids.prefix(count))
        }.thenMap { id in
            item(id: id)
        }.mapValues { item in
            item.story!
        }
        return promise
    }

    static func loadComments(of story: Story) -> Promise<Story> {
        guard let commentIds = story.commentIds else {
            return .value(story)
        }
        // Assuming that the story object is up-to date
        let topLevelCommentCount = commentIds.count
        let progress = Progress(totalUnitCount: Int64(topLevelCommentCount))
        let promises = commentIds.map { id in
            item(id: id).map { item in
                item.comment
            }.then { comment -> Promise<Comment?> in
                guard let comment = comment else {
                    return .value(nil)
                }
                return loadComments(of: comment).map { $0 }
            }.map { comment -> Comment? in
                progress.completedUnitCount += 1
                return comment
            }
        }

        let promise = firstly {
            when(fulfilled: promises)
        }.compactMapValues {
            $0
        }.map { comments -> Story in
            story.comments = comments
            return story
        }
        return promise
    }

    static func loadComments(of comment: Comment) -> Promise<Comment> {
        guard let commentIds = comment.commentIds else {
            return .value(comment)
        }
        let promises = commentIds.map { id in
            item(id: id)
        }
        let promise = firstly {
            when(fulfilled: promises)
        }.compactMapValues { item in
            item.comment
        }.thenMap { comment in
            loadComments(of: comment)
        }.map { comments -> Comment in
            comment.comments = comments
            return comment
        }
        return promise
    }
}
