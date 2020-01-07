
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
}
