
import Cocoa
import HackerNewsAPI
import PromiseKit

class ItemDetailsView: NSView {

    // MARK: - IBOutlets

    @IBOutlet var authorButton: NSButton!
    @IBOutlet var ageLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var urlButton: NSButton!
    @IBOutlet var toggleButton: NSButton!
    @IBOutlet var actionView: ActionView!

    // MARK: - Properties

    var item: TopLevelItem? {
        didSet {
            updateInterface()
        }
    }

    // MARK: - IBActions

    @IBAction func toggleContent(_ sender: NSButton) {
        if case let .story(story) = item {
            if story.text != nil {
                textLabel.isHidden.toggle()
            } else if story.url != nil {
                urlButton.isHidden.toggle()
            }
        }
    }

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        actionView.delegate = self
    }

    // MARK: - Methods

    func updateInterface() {
        if case let .story(story) = item {
            authorButton.title = story.authorName
            ageLabel.stringValue = story.ageDescription
            if let text = story.text {
                textLabel.stringValue = text
                textLabel.isHidden = false
                urlButton.isHidden = true
            } else if let url = story.url, let host = url.host {
                textLabel.isHidden = true
                urlButton.title = host
                urlButton.isHidden = false
            }
            actionView.actions = story.actions
        }
    }
}

extension ItemDetailsView: ActionViewDelegateProtocol {
    func execute(_ action: Action, token: Token) {
        if case let .story(story) = item {
            firstly {
                story.execute(action, token: token)
            }.map {
                self.updateInterface()
            }.catch { error in
                print(error)
            }
        }
    }
}
