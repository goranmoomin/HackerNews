
import Cocoa
import Combine
import HNAPI

class ItemDetailsView: NSView {

    // MARK: - IBOutlets

    @IBOutlet var authorButton: NSButton!
    @IBOutlet var ageLabel: NSTextField!
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var urlButton: NSButton!
    @IBOutlet var toggleButton: NSButton!
    @IBOutlet var actionView: ActionView!

    // MARK: - Properties

    var storage: Set<AnyCancellable> = []

    // MARK: - IBActions

    @IBAction func toggleContent(_ sender: NSButton) {
        if case let .story(story) = State.shared.page?.topLevelItem {
            switch story.content {
            case .text:
                textLabel.isHidden.toggle()
            case .url:
                urlButton.isHidden.toggle()
            }
        }
    }

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        actionView.delegate = self
        State.shared.$page.sink(receiveValue: updateInterface(page:)).store(in: &storage)
    }

    // MARK: - Methods

    func updateInterface(page: Page?) {
        if case let .story(story) = page?.topLevelItem {
            authorButton.title = story.author
            // TODO: Use DateFormatter
            ageLabel.stringValue = story.creation.description
            switch story.content {
            case let .text(text):
                textLabel.stringValue = text
                textLabel.isHidden = false
                urlButton.isHidden = true
            case let .url(url):
                let host = url.host ?? ""
                textLabel.isHidden = true
                urlButton.title = host
                urlButton.isHidden = false
            }
        }
    }
}

extension ItemDetailsView: ActionViewDelegateProtocol {
    func execute(_ action: Action, token: Token) {
        // TODO: How to get Page instance?
        State.shared.client.execute(action: action, token: token) { result in
            guard case .success = result else {
                // TODO: Error handling
                return
            }
        }
    }
}
