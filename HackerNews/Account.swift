
import Foundation
import HNAPI

struct Account {
    var username: String
    var token: Token
}

extension Account {
    static var accounts: [Account] = {
        var accounts: [Account] = []
        let dictionary = UserDefaults.standard.dictionary(forKey: "account") as? [String : [HTTPCookiePropertyKey : Any]] ?? [:]
        for (name, properties) in dictionary {
            guard let token = Token(properties: properties) else {
                print(properties)
                continue
            }

            accounts.append(Account(username: name, token: token))
        }
        return accounts
    }() {
        didSet {
            var dictionary: [String : [HTTPCookiePropertyKey : Any]] = [:]
            for account in accounts {
                guard let properties = account.token.properties else {
                    print(account)
                    continue
                }
                dictionary[account.username] = properties
            }
            UserDefaults.standard.set(dictionary, forKey: "account")
        }
    }

    static var selectedAccountIndex: Int? = {
        UserDefaults.standard.integer(forKey: "selectedAccountIndex")
    }() {
        didSet {
            UserDefaults.standard.set(selectedAccountIndex, forKey: "selectedAccountIndex")
        }
    }

    static var selectedAccount: Account? {
        guard let index = selectedAccountIndex,
              selectedAccountIndex != 0 || accounts.count > 0 else {
            return nil
        }
        return accounts[index]
    }
}
