
import Cocoa
import PromiseKit
import HackerNewsAPI

protocol ActionViewDelegateProtocol {
    func execute(_ action: Action, token: Token)
}

class ActionView: NSView, LoadableView {

    // MARK: - Properties

    var actions: Set<Action> = [] {
        didSet {
            updateInterface()
        }
    }

    // MARK: - Delegate

    var delegate: ActionViewDelegateProtocol?

    // MARK: - IBOutlets

    @IBOutlet var actionsStackView: NSStackView!
    @IBOutlet var upvoteButton: ActionButton!
    @IBOutlet var downvoteButton: ActionButton!

    // MARK: - IBActions

    @IBAction func executeAction(_ sender: ActionButton) {
        guard let delegate = delegate, let action = sender.underlyingAction, let token = State.shared.currentToken else {
            return
        }
        delegate.execute(action, token: token)
    }

    // MARK: - Methods

    func updateInterface() {
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        for action in actions {
            switch action.kind {
            case .upvote, .unvote:
                upvoteButton.underlyingAction = action
                upvoteButton.isHidden = false
            case .downvote, .undown:
                downvoteButton.underlyingAction = action
                downvoteButton.isHidden = false
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
