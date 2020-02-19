
import Cocoa
import PromiseKit
import HackerNewsAPI

class ActionView: NSView, LoadableView {

    // MARK: - Properties

    var actions: Set<Action> = [] {
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
        // TODO
        guard let action = sender.displayedAction else {
            return
        }
        firstly {
            HackerNewsAPI.execute(action)
        }.map { action in
            sender.displayedAction = action
        }.catch { error in
            print(error)
        }
    }

    // MARK: - Methods

    func updateInterface() {
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        for action in actions {
            switch action.kind {
            case .upvote, .unvote:
                upvoteButton.displayedAction = action
                upvoteButton.isHidden = false
            case .downvote, .undown:
                downvoteButton.displayedAction = action
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
