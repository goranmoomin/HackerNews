
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

    static func items(ids: [Int], shouldTrackProgress trackProgress: Bool = false) -> Promise<[Item]> {
        let idCount = ids.count
        let progress = trackProgress ? Progress(totalUnitCount: Int64(idCount)) : nil
        let promises = ids.map { id -> Promise<Item> in
            firstly {
                item(id: id)
            }.map { item -> Item in
                progress?.completedUnitCount += 1
                return item
            }
        }

        return when(fulfilled: promises)
    }

    static func ids(fromPathComponent pathComponent: String) -> Promise<[Int]> {
        let url = base.appendingPathComponent(pathComponent)
        let request = URLRequest(url: url)
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode([Int].self, from: data)
        }

        return promise
    }

    static func stories(fromPathComponent pathComponent: String, count: Int = 500) -> Promise<[Storyable]> {
        let progress = Progress(totalUnitCount: 100)
        progress.becomeCurrent(withPendingUnitCount: 0)
        let promise = firstly {
            ids(fromPathComponent: pathComponent)
        }.then { ids -> Promise<[Item]> in
            progress.resignCurrent()
            progress.becomeCurrent(withPendingUnitCount: 100)
            let ids = Array(ids.prefix(count))
            return items(ids: ids, shouldTrackProgress: true)
        }.mapValues { item in
            item.story!
        }.map { stories -> [Storyable] in
            progress.resignCurrent()
            return stories
        }
        return promise
    }

    static func topStories(count: Int = 500) -> Promise<[Storyable]> {
        return stories(fromPathComponent: "topstories.json", count: count)
    }

    static func newStories(count: Int = 500) -> Promise<[Storyable]> {
        return stories(fromPathComponent: "newstories.json", count: count)
    }

    static func bestStories(count: Int = 500) -> Promise<[Storyable]> {
        stories(fromPathComponent: "beststories.json", count: count)
    }

    static func loadComments(of story: Story) -> Promise<Story> {
        guard let commentIds = story.commentIds else {
            return .value(story)
        }
        // Assuming that the story object is up-to date
        let topLevelCommentCount = commentIds.count
        let progress = Progress(totalUnitCount: Int64(topLevelCommentCount))

        let promise = firstly {
            items(ids: commentIds)
        }.compactMapValues { item in
            item.comment
        }.thenMap { comment -> Promise<Comment> in
            firstly {
                loadComments(of: comment)
            }.map { comment -> Comment in
                progress.completedUnitCount += 1
                return comment
            }
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

        let promise = firstly {
            items(ids: commentIds)
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
