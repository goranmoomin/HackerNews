
import Cocoa
import PromiseKit
import HackerNewsAPI

class AuthorPopupViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var userNameLabel: NSTextField!
    @IBOutlet var karmaLabel: NSTextField!
    @IBOutlet var createdDateLabel: NSTextField!
    @IBOutlet var selfDescriptionLabel: NSTextField!

    // MARK: - Properties

    var userName: String? {
        didSet {
            guard let userName = userName else {
                return
            }
            firstly {
                HackerNewsAPI.user(withName: userName)
            }.done { user in
                self.user = user
            }.catch { error in
                print(error)
            }
        }
    }

    var user: User? {
        didSet {
            updateInterface()
        }
    }

    // MARK: - Methods

    func formattedCreatedDate() -> String {
        guard let user = user else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.formattingContext = .standalone
        formatter.dateStyle = .medium
        let createdDate = formatter.string(from: user.creation)
        return createdDate
    }

    func updateInterface() {
        guard let user = user else {
            view.isHidden = true
            return
        }
        userNameLabel.stringValue = user.name
        karmaLabel.stringValue = String(user.karma)
        createdDateLabel.stringValue = formattedCreatedDate()
        selfDescriptionLabel.stringValue = user.description
        view.isHidden = false
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        updateInterface()
    }
}
