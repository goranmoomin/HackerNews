import Atributika
import Cocoa
import HNAPI

class ItemViewController: NSViewController {

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var storyTextScrollView: NSScrollView!
    @IBOutlet var storyTextView: NSTextView!
    @IBOutlet var urlButton: NSButton!
    @IBOutlet var authorGroup: NSStackView!
    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var pointsGroup: NSStackView!
    @IBOutlet var pointsLabel: NSTextField!
    @IBOutlet var commentCountGroup: NSStackView!
    @IBOutlet var commentCountLabel: NSTextField!
    @IBOutlet var creationLabel: NSTextField!
    @IBOutlet var upvoteButton: NSButton!
    @IBOutlet var replyButton: NSButton!
    var upvoteAction: Action?

    let formatter = RelativeDateTimeFormatter()

    var item: TopLevelItem? {
        didSet {
            actions = []
            guard let item = item else { return }
            switch item {
            case .story(let story):
                titleLabel.stringValue = story.title
                if let host = story.content.url?.host {
                    storyTextScrollView.isHidden = true
                    urlButton.isHidden = false
                    urlButton.title = host
                } else if let text = story.content.text {
                    storyTextView.textStorage?
                        .setAttributedString(text.styledAttributedString(textColor: .labelColor))
                    storyTextScrollView.isHidden = false
                    urlButton.isHidden = true
                } else {
                    storyTextScrollView.isHidden = true
                    urlButton.isHidden = true
                }
                authorGroup.isHidden = false
                authorLabel.stringValue = story.author
                pointsGroup.isHidden = false
                pointsLabel.stringValue = String(story.points)
                commentCountGroup.isHidden = false
                commentCountLabel.stringValue = String(story.commentCount)
                creationLabel.stringValue = formatter.localizedString(
                    for: story.creation, relativeTo: Date())
            case .job(let job):
                titleLabel.stringValue = job.title
                authorGroup.isHidden = true
                pointsGroup.isHidden = true
                commentCountGroup.isHidden = true
                creationLabel.stringValue = formatter.localizedString(
                    for: job.creation, relativeTo: Date())
            }
        }
    }

    var page: Page? {
        didSet {
            DispatchQueue.main.async {
                self.item = self.page?.topLevelItem
                if let item = self.item { self.actions = self.page?.actions[item.id] ?? [] }
            }
        }
    }

    var actions: Set<Action> = [] {
        didSet {
            DispatchQueue.main.async {
                self.upvoteButton.isHidden = true
                for action in self.actions {
                    switch action {
                    case .upvote:
                        self.upvoteButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
                        self.upvoteButton.isHidden = false
                        self.upvoteAction = action
                    case .unvote:
                        self.upvoteButton.font = NSFont.boldSystemFont(
                            ofSize: NSFont.systemFontSize)
                        self.upvoteButton.isHidden = false
                        self.upvoteAction = action
                    default: break
                    }
                }
            }
        }
    }

    @IBAction func openURL(_ sender: NSButton) {
        let url: URL
        switch item {
        case .story(let story):
            guard story.content.url != nil else { return }
            url = story.content.url!
        case .job(let job):
            guard job.content.url != nil else { return }
            url = job.content.url!
        default: return
        }
        NSWorkspace.shared.open(url)
    }

    @IBAction func executeAction(_ sender: NSButton) {
        guard let token = Account.selectedAccount?.token else { return }
        APIClient.shared.execute(action: upvoteAction!, token: token, page: page) { result in
            switch result {
            case .success:
                guard let id = self.item?.id else { return }
                DispatchQueue.main.async { self.actions = self.page?.actions[id] ?? [] }
            case .failure(let error):
                DispatchQueue.main.async { NSApplication.shared.presentError(error) }
            }
        }
    }

    var isReplyPopoverShown = false

    @IBAction func showReplyPopover(_ sender: NSButton) {
        guard !isReplyPopoverShown else { return }
        let replyPopoverViewController =
            NSStoryboard.main?
            .instantiateController(withIdentifier: .itemReplyPopoverViewController)
            as! ReplyPopoverViewController
        replyPopoverViewController.delegate = self
        let title: String
        switch item! {
        case .story(let story): title = story.title
        case .job(let job): title = job.title
        }
        replyPopoverViewController.title = "Comment to \(title)"
        replyPopoverViewController.commentable = item
        let popover = NSPopover()
        popover.contentViewController = replyPopoverViewController
        popover.delegate = replyPopoverViewController
        popover.show(relativeTo: .zero, of: replyButton, preferredEdge: .minY)
        isReplyPopoverShown = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()  // Do view setup here.
    }
}

extension ItemViewController: ReplyPopoverViewControllerDelegate {
    func replyDidSubmit(_ replyPopoverViewController: ReplyPopoverViewController) {
        isReplyPopoverShown = false
    }
    func replyDidCancel(_ replyPopoverViewController: ReplyPopoverViewController) {
        isReplyPopoverShown = false
    }
}
