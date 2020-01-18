
import Cocoa
import PromiseKit

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
                HackerNewsAPI.user(named: userName)
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

    func formattedSelfDescription() -> String {
        let descriptionData = user?.selfDescription?.data(using: .utf16) ?? Data()
        let attributedString = NSAttributedString(html: descriptionData, documentAttributes: nil)
        let selfDescription = attributedString?.string.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return selfDescription
    }

    func updateInterface() {
        guard let user = user else {
            view.isHidden = true
            return
        }
        view.isHidden = false
        userNameLabel.stringValue = user.name
        karmaLabel.stringValue = String(user.karma)
        createdDateLabel.stringValue = formattedCreatedDate()
        selfDescriptionLabel.stringValue = formattedSelfDescription()
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        updateInterface()
    }
}
