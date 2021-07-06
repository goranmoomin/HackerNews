import Foundation
import HNAPI

struct Account {
    var username: String
    var token: Token
}

extension HTTPCookiePropertyKey: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Account: Codable {
    enum CodingKeys: CodingKey {
        case username
        case token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        let properties = try container.decode([HTTPCookiePropertyKey: String].self, forKey: .token)
        token = Token(properties: properties)!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(
            token.properties?.compactMapValues { $0 as? String } ?? [:], forKey: .token)
    }
}

extension Account {
    static var accounts: [Account] = {
        guard let data = UserDefaults.standard.data(forKey: "Accounts") else { return [] }
        return (try? JSONDecoder().decode([Account].self, from: data)) ?? []
    }()
    {
        didSet {
            try! UserDefaults.standard.set(JSONEncoder().encode(accounts), forKey: "Accounts")
            if accounts.count == 0 { selectedAccountUsername = nil }
        }
    }

    static var selectedAccountUsername: String? = {
        UserDefaults.standard.string(forKey: "SelectedAccountUsername")
    }()
    {
        didSet {
            UserDefaults.standard.set(selectedAccountUsername, forKey: "SelectedAccountUsername")
        }
    }

    static var selectedAccount: Account? {
        accounts.first(where: { $0.username == selectedAccountUsername })
    }
    static var selectedAccountIndex: Int? {
        accounts.firstIndex(where: { $0.username == selectedAccountUsername })
    }
}
