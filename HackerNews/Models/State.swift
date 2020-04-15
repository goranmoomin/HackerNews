
import Foundation
import HNAPI
import Defaults
import Combine

class State {
    static var shared = State()
    let client = APIClient()
    @Published var token: Token?
    @Published var category: HNAPI.Category = .top
    @Published var item: TopLevelItem?
    @Published var page: Page?

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
