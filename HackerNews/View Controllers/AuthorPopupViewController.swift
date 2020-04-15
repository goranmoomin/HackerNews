
import Cocoa
import HNAPI

class AuthorPopupViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var userNameLabel: NSTextField!
    @IBOutlet var karmaLabel: NSTextField!
    @IBOutlet var createdDateLabel: NSTextField!
    @IBOutlet var selfDescriptionLabel: NSTextField!

    // MARK: - Properties

    var userName: String? {
        didSet {
        }
    }

    // MARK: - Methods

    func updateInterface() {
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        updateInterface()
    }
}
