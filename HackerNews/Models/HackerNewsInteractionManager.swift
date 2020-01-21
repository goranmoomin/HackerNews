
import Foundation
import PromiseKit
import PMKFoundation
import SwiftSoup

class HackerNewsInteractionManager {

    // MARK: - Error

    enum HNError: Error {
        case authenticationError
    }

    // MARK: - Properties

    let hackerNews = URLComponents(string: "https://news.ycombinator.com/")!
    let urlSession = URLSession.shared
    let cookieStorage = HTTPCookieStorage.shared
    var authCookie: HTTPCookie? {
        cookieStorage.cookies(for: hackerNews.url!)?.first(where: { $0.name == "user" })
    }
    var isAuthorized: Bool {
        authCookie != nil
    }
    var authKeys: [Int : String] = [:]

    // MARK: - Login

    func isAuthorized(asAccount account: String) -> Bool {
        guard let authCookie = authCookie else {
            return false
        }
        return authCookie.value.starts(with: account)
    }

    func login(toAccount account: String, withPassword password: String) -> Promise<Void> {
        if isAuthorized(asAccount: account) {
            return .value
        }
        logout()
        var hackerNews = self.hackerNews
        hackerNews.path = "/login"
        hackerNews.queryItems = [
            URLQueryItem(name: "acct", value: account),
            URLQueryItem(name: "pw", value: password)
        ]
        let request = URLRequest(url: hackerNews.url!)
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { _ in
            guard self.isAuthorized(asAccount: account) else {
                throw HNError.authenticationError
            }
        }
        return promise
    }

    func logout() {
        guard let authCookie = authCookie else {
            return
        }
        cookieStorage.deleteCookie(authCookie)
    }

    // MARK: - Auth Keys

    func loadAuthKeys(for story: Story) -> Promise<Void> {
        guard isAuthorized else {
            return Promise(error: HNError.authenticationError)
        }
        var hackerNews = self.hackerNews
        hackerNews.path = "/item"
        hackerNews.queryItems = [
            URLQueryItem(name: "id", value: String(story.id))
        ]
        let request = URLRequest(url: hackerNews.url!)
        let promise = firstly {
            urlSession.dataTask(.promise, with: request).validate()
        }.map { (data, response) -> [URLComponents] in
            let html = String(data: data, urlResponse: response)!
            let document = try SwiftSoup.parse(html)
            let voteLinks = try document.select("a:has(.votearrow)").compactMap({ voteArrow in
                URLComponents(string: try voteArrow.attr("href"))
            })
            return voteLinks
        }.mapValues { voteLink in
            let queryItems = voteLink.queryItems
            guard let authKey = queryItems?.first(where: { $0.name == "auth" })?.value, let id = Int(queryItems?.first(where: { $0.name == "id" })?.value ?? "") else {
                return
            }
            self.authKeys[id] = authKey
        }.asVoid()
        return promise
    }
}
