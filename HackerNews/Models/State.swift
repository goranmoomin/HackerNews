
import Foundation
import HNAPI
import Defaults

class State {
    static var shared = State()
    var client = APIClient()
    var token: Token? = nil

    static func performLogin() {
        guard
            let account = Defaults[.selectedAccount],
            let password = Defaults[.accounts][account] else {
            shared.token = nil
            return
        }
        shared.client.login(userName: account, password: password) { result in
            guard case let .success(token) = result else {
                // TODO: Handle failure
                return
            }
            shared.token = token
        }
    }
}
