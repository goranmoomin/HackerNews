
import Foundation
import PromiseKit
import Firebase
import FirebaseDatabase

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
        }.thenMap { storyable -> Promise<Storyable> in
            guard let story = storyable as? Story else {
                return .value(storyable)
            }
            let promise = firstly {
                story.loadComments()
            }.map { storyable }
            return promise
        }
        return promise
    }

    static let database: Database = {
        FirebaseApp.configure()
        return Database.database()
    }()
    static var baseRef = database.reference(withPath: "v0")

    static func firebaseItem(id: Int) -> Promise<Item> {
        let itemRef = baseRef.child("item").child("\(id)")
        let promise: Promise<Item> = firstly {
            itemRef.observeSingleEvent(of: .value)
        }.map { dataSnapshot in
            let dict = dataSnapshot.value as! NSDictionary
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let decoder = JSONDecoder()
            let item = try decoder.decode(Item.self, from: data)
            return item
        }

        return promise
    }

    static func firebaseTopStories(count: Int = 500) -> Promise<[Storyable]> {
        let topStoriesRef = baseRef.child("topstories")
        let slicedTopStoriesRef = topStoriesRef.queryLimited(toFirst: UInt(count))
        let promise: Promise<[Storyable]> = firstly {
            slicedTopStoriesRef.observeSingleEvent(of: .value)
        }.map { dataSnapshot -> [Int] in
            let array = dataSnapshot.value as! NSArray
            let data = try JSONSerialization.data(withJSONObject: array, options: [])
            let decoder = JSONDecoder()
            let ids = try decoder.decode([Int].self, from: data)
            return ids
        }.thenMap { id in
            firebaseItem(id: id)
        }.mapValues { item in
            item.story!
        }.thenMap { storyable -> Promise<Storyable> in
            guard let story = storyable as? Story else {
                return .value(storyable)
            }
            let promise = firstly {
                story.loadComments()
            }.map { storyable }
            return promise
        }
        return promise
    }
}
