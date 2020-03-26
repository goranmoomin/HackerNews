
import Foundation
import PromiseKit
import HackerNewsAPI
import Defaults

class State {
    static var shared = State()
    var currentToken: Token? = nil

    static func performLogin() {
        guard
            let account = Defaults[.selectedAccount],
            let password = Defaults[.accounts][account] else {
            shared.currentToken = nil
            return
        }
        firstly {
            HackerNewsAPI.login(toAccount: account, password: password)
        }.map { token in
            shared.currentToken = token
        }.catch { error in
            print(error)
            shared.currentToken = nil
        }
    }
}
