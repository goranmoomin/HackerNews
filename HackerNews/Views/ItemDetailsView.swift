
import Cocoa
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

    var page: Page? {
        didSet {
            updateInterface()
        }
    }

    var item: TopLevelItem? {
        guard let page = page else {
            return nil
        }
        return page.topLevelItem
    }

    let formatter = RelativeDateTimeFormatter()

    // MARK: - IBActions

    @IBAction func toggleContent(_ sender: NSButton) {
        if case let .story(story) = item {
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
    }

    // MARK: - Methods

    func updateInterface() {
        if case let .story(story) = item {
            authorButton.title = story.author
            ageLabel.stringValue = formatter.localizedString(for: story.creation, relativeTo: Date())
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
        APIClient.shared.execute(action: action, token: token) { result in
            guard case .success = result else {
                // TODO: Error handling
                return
            }
        }
    }
}
