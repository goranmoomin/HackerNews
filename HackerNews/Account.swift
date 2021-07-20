import Foundation
import HNAPI

struct Account: Codable {
    var username: String
    var password: String
}

extension Account {
    static var accountUsernames: [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: "news.ycombinator.com",
            kSecMatchLimit as String: kSecMatchLimitAll, kSecReturnAttributes as String: true,
        ]
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status != errSecItemNotFound else { return [] }
        guard status == errSecSuccess else {
            print("SecItemCopyMatching return value: \(status)")
            let statusString = SecCopyErrorMessageString(status, nil)
            print(statusString ?? "Unknown status code.")
            return []
        }
        guard let items = items as? [[String: Any]] else { return [] }
        let usernames = items.compactMap { $0[kSecAttrAccount as String] as? String }.sorted()
        return usernames
    }

    static func addAccount(_ account: Account) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account.username,
            kSecAttrServer as String: "news.ycombinator.com",
            kSecValueData as String: account.password,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("SecItemAdd return value: \(status)")
            let statusString = SecCopyErrorMessageString(status, nil)
            print(statusString ?? "Unknown status code.")
            return
        }
    }

    static func selectAccount(withUsername username: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword, kSecAttrAccount as String: username,
            kSecAttrServer as String: "news.ycombinator.com",
            kSecReturnPersistentRef as String: true,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("SecItemCopyMatching return value: \(status)")
            let statusString = SecCopyErrorMessageString(status, nil)
            print(statusString ?? "Unknown status code.")
            return
        }
        guard let accountRef = item as? Data else { return }
        selectedAccountRef = accountRef
    }

    static func removeAccount(withUsername username: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword, kSecAttrAccount as String: username,
            kSecAttrServer as String: "news.ycombinator.com",
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            print("SecItemDelete return value: \(status)")
            let statusString = SecCopyErrorMessageString(status, nil)
            print(statusString ?? "Unknown status code.")
            return
        }
    }

    static private var selectedAccountRef: Data? {
        get { UserDefaults.standard.data(forKey: "SelectedAccountRef") }
        set { UserDefaults.standard.set(newValue, forKey: "SelectedAccountRef") }
    }

    static var selectedAccount: Account? {
        guard let selectedAccountRef = selectedAccountRef else { return nil }
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecMatchItemList as String: [selectedAccountRef] as CFArray,
            kSecMatchLimit as String: kSecMatchLimitOne, kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("SecItemCopyMatching return value: \(status)")
            let statusString = SecCopyErrorMessageString(status, nil)
            print(statusString ?? "Unknown status code.")
            return nil
        }
        guard let item = item as? [String: Any] else { return nil }
        guard let passwordData = item[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let username = item[kSecAttrAccount as String] as? String
        else { return nil }
        return Account(username: username, password: password)
    }

    static var selectedAccountIndex: Int? {
        accountUsernames.firstIndex { $0 == selectedAccount?.username }
    }
}
