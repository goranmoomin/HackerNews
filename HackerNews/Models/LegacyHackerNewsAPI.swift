
import Foundation
import PromiseKit
import PMKFoundation

class LegacyHackerNewsAPI {

    // MARK: - Static Variables

    static let urlSession = URLSession.shared
    static let interactionManager = LegacyHackerNewsInteractionManager()
    static let algoliaAPI: URLComponents = URLComponents(string: "https://hn.algolia.com/api/v1/")!
    static let firebaseAPI = URLComponents(string: "https://hacker-news.firebaseio.com/v0/")!

    // MARK: - Items

    static func item(id: Int) -> Promise<LegacyItem> {
        var firebaseAPI = Self.firebaseAPI
        firebaseAPI.path += "item/\(id).json"
        let request = URLRequest(url: firebaseAPI.url!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode(LegacyItem.self, from: data)
        }
        return promise
    }

    static func items(ids: [Int]) -> Promise<[LegacyItem]> {
        let idCount = ids.count
        let progress = Progress(totalUnitCount: Int64(idCount))
        let promises = ids.map { id -> Promise<LegacyItem> in
            firstly {
                item(id: id)
            }.map { item -> LegacyItem in
                progress.completedUnitCount += 1
                return item
            }
        }

        return when(fulfilled: promises)
    }

    // MARK: - Users

    static func user(named name: String) -> Promise<LegacyUser> {
        var firebaseAPI = Self.firebaseAPI
        firebaseAPI.path += "user/\(name).json"
        let request = URLRequest(url: firebaseAPI.url!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode(LegacyUser.self, from: data)
        }
        return promise
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

    static func stories(fromFirebasePath path: String, count: Int = 500) -> Promise<[LegacyStoryable]> {
        let progress = Progress(totalUnitCount: 100)
        progress.becomeCurrent(withPendingUnitCount: 0)
        let promise = firstly {
            ids(fromFirebasePath: path)
        }.then { ids -> Promise<[LegacyItem]> in
            progress.becomeCurrent(withPendingUnitCount: 100)
            let ids = Array(ids.prefix(count))
            let promise = items(ids: ids)
            progress.resignCurrent()
            return promise
        }.mapValues { item in
            item.story!
        }.map { stories -> [LegacyStoryable] in
            return stories
        }
        progress.resignCurrent()
        return promise
    }

    static func stories(fromAlgoliaPath path: String, with queryItems: [URLQueryItem]) -> Promise<[LegacyStoryable]> {
        let progress = Progress(totalUnitCount: 100)
        progress.becomeCurrent(withPendingUnitCount: 0)
        let promise = firstly {
            ids(fromAlgoliaPath: path, with: queryItems)
        }.then { ids -> Promise<[LegacyItem]> in
            progress.becomeCurrent(withPendingUnitCount: 100)
            let promise = items(ids: ids)
            progress.resignCurrent()
            return promise
        }.mapValues { item in
            item.story!
        }.map { stories -> [LegacyStoryable] in
            return stories
        }
        progress.resignCurrent()
        return promise
    }

    // MARK: - Categories

    static func stories(from category: LegacyCategory, count: Int = 500) -> Promise<[LegacyStoryable]> {
        return stories(fromFirebasePath: "\(category.rawValue).json", count: count)
    }

    // MARK: - Search

    static func stories(matching query: String) -> Promise<[LegacyStoryable]> {
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "tags", value: "story")
        ]
        return stories(fromAlgoliaPath: "search", with: queryItems)
    }

    // MARK: - Comments

    static func loadComments(of story: LegacyStory) -> Promise<LegacyStory> {
        guard let commentIds = story.commentIds else {
            return .value(story)
        }
        let progress = Progress(totalUnitCount: Int64(2 * commentIds.count))
        progress.becomeCurrent(withPendingUnitCount: Int64(commentIds.count))
        let promise = firstly {
            items(ids: commentIds)
        }.compactMapValues { item in
            item.comment
        }.thenMap { comment -> Promise<LegacyComment> in
            progress.becomeCurrent(withPendingUnitCount: 1)
            let promise = loadComments(of: comment)
            progress.resignCurrent()
            return promise
        }.map { comments -> LegacyStory in
            progress.completedUnitCount = progress.totalUnitCount
            story.comments = comments
            return story
        }
        progress.resignCurrent()
        return promise
    }

    static func loadComments(of comment: LegacyComment) -> Promise<LegacyComment> {
        guard let commentIds = comment.commentIds else {
            return .value(comment)
        }
        let progress = Progress(totalUnitCount: Int64(2 * commentIds.count))
        progress.becomeCurrent(withPendingUnitCount: Int64(commentIds.count))
        let promise = firstly {
            items(ids: commentIds)
        }.compactMapValues { item in
            item.comment
        }.thenMap { comment -> Promise<LegacyComment> in
            progress.becomeCurrent(withPendingUnitCount: 1)
            let promise = loadComments(of: comment)
            progress.resignCurrent()
            return promise
        }.map { comments -> LegacyComment in
            progress.completedUnitCount = progress.totalUnitCount
            comment.comments = comments
            return comment
        }
        progress.resignCurrent()
        return promise
    }

    // MARK: - Authors

    static func loadAuthor(of item: LegacyItemable) -> Promise<LegacyItemable> {
        let authorName = item.authorName
        let promise = firstly {
            user(named: authorName)
        }.map { author -> LegacyItemable in
            item.author = author
            return item
        }
        return promise
    }
}
