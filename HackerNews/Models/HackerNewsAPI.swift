
import Foundation
import PromiseKit

class HackerNewsAPI {

    static let urlSession = URLSession.shared
    static let algoliaURL = URL(string: "http://hn.algolia.com/api/v1/")!
    static let firebaseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!

    static func item(id: Int) -> Promise<Item> {
        let request = URLRequest(url: algoliaURL.appendingPathComponent("items/\(id)"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let promise = firstly {
            urlSession.dataTask(.promise, with: request)
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

    static func ids(fromPathComponent pathComponent: String) -> Promise<[Int]> {
        let url = firebaseURL.appendingPathComponent(pathComponent)
        let request = URLRequest(url: url)
        let decoder = JSONDecoder()
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, _) in
            try decoder.decode([Int].self, from: data)
        }

        return promise
    }

    // MARK: - Stories

    static func stories(fromPathComponent pathComponent: String, count: Int = 500) -> Promise<[Storyable]> {
        let progress = Progress(totalUnitCount: 100)
        progress.becomeCurrent(withPendingUnitCount: 0)
        let promise = firstly {
            ids(fromPathComponent: pathComponent)
        }.then { ids -> Promise<[Item]> in
            progress.resignCurrent()
            progress.becomeCurrent(withPendingUnitCount: 100)
            let ids = Array(ids.prefix(count))
            return items(ids: ids)
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
}
