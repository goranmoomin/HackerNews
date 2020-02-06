
import Cocoa
import PromiseKit

class ActionView: NSView, LoadableView {

    // MARK: - Properties

    var actions: Set<LegacyAction> = [] {
        didSet {
            updateInterface()
        }
    }

    // MARK: - IBOutlets

    @IBOutlet var actionsStackView: NSStackView!
    @IBOutlet var upvoteButton: ActionButton!
    @IBOutlet var downvoteButton: ActionButton!

    // MARK: - IBActions

    @IBAction func executeAction(_ sender: ActionButton) {
        guard let action = sender.representedAction else {
            return
        }
        firstly {
            LegacyHackerNewsAPI.interactionManager.execute(action)
        }.catch { error in
            print(error)
        }
    }

    // MARK: - Methods

    func updateInterface() {
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        for action in actions {
            switch action {
            case .upvote:
                upvoteButton.isHidden = false
                upvoteButton.representedAction = action
            case .downvote:
                downvoteButton.isHidden = false
                downvoteButton.representedAction = action
            }
        }
    }

    // MARK: - Init

    var mainView: NSView?

    func commonInit() {
        loadFromNib()
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}
