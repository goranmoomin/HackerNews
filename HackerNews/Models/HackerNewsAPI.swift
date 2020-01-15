
import Foundation
import Combine

class HackerNewsAPI {

    // MARK: - Static Variables

    static let urlSession = URLSession.shared
    static let algoliaAPI: URLComponents = URLComponents(string: "http://hn.algolia.com/api/v1/")!
    static let firebaseAPI = URLComponents(string: "https://hacker-news.firebaseio.com/v0/")!

    // MARK: - Items

    static func item(id: Int) -> AnyPublisher<Item, Error> {
        var algoliaAPI = Self.algoliaAPI
        algoliaAPI.path += "items/\(id)"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let publisher = urlSession.dataTaskPublisher(for: algoliaAPI.url!)
            .map(\.data)
            .decode(type: Item.self, decoder: decoder)
            .eraseToAnyPublisher()
        return publisher
    }

    static func items(ids: [Int]) -> AnyPublisher<Item, Error> {
        let publisher = Publishers.Sequence(sequence: ids)
            .flatMap({ item(id: $0) })
            .eraseToAnyPublisher()
        return publisher
    }

    // MARK: - Stories

    static func ids(fromFirebasePath path: String) -> AnyPublisher<Int, Error> {
        var firebaseAPI = Self.firebaseAPI
        firebaseAPI.path += path
        let decoder = JSONDecoder()
        let publisher = urlSession.dataTaskPublisher(for: firebaseAPI.url!)
            .map(\.data)
            .decode(type: [Int].self, decoder: decoder)
            .sequence()
            .eraseToAnyPublisher()
        return publisher
    }

    static func ids(fromAlgoliaPath path: String, with queryItems: [URLQueryItem]) -> AnyPublisher<Int, Error> {
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
        let decoder = JSONDecoder()
        let publisher = urlSession.dataTaskPublisher(for: algoliaAPI.url!)
            .map(\.data)
            .decode(type: Stories.self, decoder: decoder)
            .map({ $0.hits.compactMap({ Int($0.objectID) }) })
            .sequence()
            .eraseToAnyPublisher()
        return publisher
    }

    static func stories(fromFirebasePath path: String, count: Int = 500) -> AnyPublisher<Storyable, Error> {
        let publisher = ids(fromFirebasePath: path)
            .prefix(count)
            .flatMap({ item(id: $0) })
            .map(\.story!)
            .eraseToAnyPublisher()
        return publisher
    }

    static func stories(fromAlgoliaPath path: String, with queryItems: [URLQueryItem]) -> AnyPublisher<Storyable, Error> {
        let publisher = ids(fromAlgoliaPath: path, with: queryItems)
            .flatMap({ item(id: $0) })
            .map(\.story!)
            .eraseToAnyPublisher()
        return publisher
    }

    static func topStories(count: Int = 500) -> AnyPublisher<Storyable, Error> {
        return stories(fromFirebasePath: "topstories.json", count: count)
    }

    static func newStories(count: Int = 500) -> AnyPublisher<Storyable, Error> {
        return stories(fromFirebasePath: "newstories.json", count: count)
    }

    static func bestStories(count: Int = 500) -> AnyPublisher<Storyable, Error> {
        return stories(fromFirebasePath: "beststories.json", count: count)
    }

    // MARK: - Search

    static func stories(matching query: String) -> AnyPublisher<Storyable, Error> {
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "tags", value: "story")
        ]
        return stories(fromAlgoliaPath: "search", with: queryItems)
    }
}
