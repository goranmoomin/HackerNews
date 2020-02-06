
import Foundation
import PromiseKit
import PMKFoundation
import SwiftSoup

class LegacyHackerNewsInteractionManager {

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

    // MARK: - Actions

    func loadActions(for story: LegacyStory) -> Promise<LegacyStory> {
        guard isAuthorized else {
            return .value(story)
        }
        var actions: [Int : Set<LegacyAction>] = [:]
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
            let voteLinks = try document.select("a:has(.votearrow):not(.nosee)").compactMap { voteArrow in
                URLComponents(string: try voteArrow.attr("href"))
            }
            return voteLinks
        }.mapValues { voteLink in
            let queryItems = voteLink.queryItems
            guard let id = Int(queryItems?.first(where: { $0.name == "id" })?.value ?? ""), let type = queryItems?.first(where: { $0.name == "how" })?.value else {
                return
            }
            let voteURL = voteLink.url(relativeTo: hackerNews.url!)!
            let action: LegacyAction = type == "up" ? .upvote(voteURL) : .downvote(voteURL)
            if actions[id] == nil {
                actions[id] = []
            }
            actions[id]?.insert(action)
        }.map { _ -> LegacyStory in
            self.setActions(for: story, from: actions)
            return story
        }
        return promise
    }

    func setActions(for story: LegacyStory, from dict: [Int : Set<LegacyAction>]) {
        if let actions = dict[story.id] {
            story.availableActions = actions
        }
        for comment in story.comments {
            setActions(for: comment, from: dict)
        }
    }

    func setActions(for comment: LegacyComment, from dict: [Int : Set<LegacyAction>]) {
        if let actions = dict[comment.id] {
            comment.availableActions = actions
        }
        for comment in comment.comments {
            setActions(for: comment, from: dict)
        }

    }

    func execute(_ action: LegacyAction) -> Promise<Void> {
        let request = URLRequest(url: action.url)
        let promise = urlSession.dataTask(.promise, with: request).validate().asVoid()
        return promise
    }
}
