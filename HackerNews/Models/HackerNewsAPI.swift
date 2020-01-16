
import Foundation
import PromiseKit
import PMKFoundation

class HackerNewsAPI {

    // MARK: - Static Variables

    static let urlSession = URLSession.shared
    static let algoliaAPI: URLComponents = URLComponents(string: "http://hn.algolia.com/api/v1/")!
    static let firebaseAPI = URLComponents(string: "https://hacker-news.firebaseio.com/v0/")!

    // MARK: - Items

    static func item(id: Int) -> Promise<Item> {
        var firebaseAPI = Self.firebaseAPI
        firebaseAPI.path += "item/\(id).json"
        let request = URLRequest(url: firebaseAPI.url!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode(Item.self, from: data)
        }
        return promise
    }

    static func items(ids: [Int]) -> Promise<[Item]> {
        let idCount = ids.count
        let progress = Progress(totalUnitCount: Int64(idCount))
        let promises = ids.map { id -> Promise<Item> in
            firstly {
                item(id: id)
            }.map { item -> Item in
                progress.completedUnitCount += 1
                return item
            }
        }

        return when(fulfilled: promises)
    }

    // MARK: - Stories

    static func ids(fromFirebasePath path: String) -> Promise<[Int]> {
        var firebaseAPI = Self.firebaseAPI
        firebaseAPI.path += path
        let request = URLRequest(url: firebaseAPI.url!)
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode([Int].self, from: data)
        }

        return promise
    }

    static func ids(fromAlgoliaPath path: String, with queryItems: [URLQueryItem]) -> Promise<[Int]> {
        struct Stories: Decodable {
            let hits: [Hit]
        }
        struct Hit: Decodable {
            let objectID: String
        }

        var algoliaAPI = Self.algoliaAPI
        algoliaAPI.path += path
        if algoliaAPI.queryItems == nil {
            algoliaAPI.queryItems = []
        }
        algoliaAPI.queryItems! += queryItems
        let request = URLRequest(url: algoliaAPI.url!)
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode(Stories.self, from: data)
        }.map { stories in
            stories.hits.compactMap { Int($0.objectID) }
        }

        return promise
    }

    static func stories(fromFirebasePath path: String, count: Int = 500) -> Promise<[Storyable]> {
        let progress = Progress(totalUnitCount: 100)
        progress.becomeCurrent(withPendingUnitCount: 0)
        let promise = firstly {
            ids(fromFirebasePath: path)
        }.then { ids -> Promise<[Item]> in
            progress.becomeCurrent(withPendingUnitCount: 100)
            let ids = Array(ids.prefix(count))
            let promise = items(ids: ids)
            progress.resignCurrent()
            return promise
        }.mapValues { item in
            item.story!
        }.map { stories -> [Storyable] in
            return stories
        }
        progress.resignCurrent()
        return promise
    }

    static func stories(fromAlgoliaPath path: String, with queryItems: [URLQueryItem]) -> Promise<[Storyable]> {
        let progress = Progress(totalUnitCount: 100)
        progress.becomeCurrent(withPendingUnitCount: 0)
        let promise = firstly {
            ids(fromAlgoliaPath: path, with: queryItems)
        }.then { ids -> Promise<[Item]> in
            progress.becomeCurrent(withPendingUnitCount: 100)
            let promise = items(ids: ids)
            progress.resignCurrent()
            return promise
        }.mapValues { item in
            item.story!
        }.map { stories -> [Storyable] in
            return stories
        }
        progress.resignCurrent()
        return promise
    }

    static func topStories(count: Int = 500) -> Promise<[Storyable]> {
        return stories(fromFirebasePath: "topstories.json", count: count)
    }

    static func newStories(count: Int = 500) -> Promise<[Storyable]> {
        return stories(fromFirebasePath: "newstories.json", count: count)
    }

    static func bestStories(count: Int = 500) -> Promise<[Storyable]> {
        return stories(fromFirebasePath: "beststories.json", count: count)
    }

    // MARK: - Search

    static func stories(matching query: String) -> Promise<[Storyable]> {
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "tags", value: "story")
        ]
        return stories(fromAlgoliaPath: "search", with: queryItems)
    }

    // MARK: - Comments

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
