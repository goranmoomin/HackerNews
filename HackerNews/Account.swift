import Foundation
import HNAPI

struct Account: Codable {
    var username: String
    var password: String
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
