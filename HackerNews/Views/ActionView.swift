
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
    @IBOutlet var upvoteButton: NSButton!
    @IBOutlet var downvoteButton: NSButton!
    @IBOutlet var unvoteButton: NSButton!
    @IBOutlet var undownButton: NSButton!

    // MARK: - IBActions

    @IBAction func executeAction(_ sender: NSButton) {
        // TODO
    }

    // MARK: - Methods

    func updateInterface() {
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        unvoteButton.isHidden = true
        undownButton.isHidden = true
        for action in actions {
            switch action.kind {
            case .upvote:
                upvoteButton.isHidden = false
            case .downvote:
                downvoteButton.isHidden = false
            case .unvote:
                unvoteButton.isHidden = false
            case .undown:
                undownButton.isHidden = false
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
