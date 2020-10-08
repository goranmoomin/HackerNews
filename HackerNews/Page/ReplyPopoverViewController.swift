
import Cocoa
import HNAPI

class ReplyPopoverViewController: NSViewController {

    @IBOutlet var commentLabel: NSTextField!
    @IBOutlet var dragLabel: NSTextField!
    @IBOutlet var replyTextView: NSTextView!
    @IBOutlet var spinner: NSProgressIndicator!

    var comment: Comment! {
        didSet {
            let textColor: NSColor
            switch comment.color {
            case .c00: textColor = .labelColor
            case .c5a, .c73, .c82: textColor = .secondaryLabelColor
            case .c88, .c9c, .cae: textColor = .tertiaryLabelColor
            case .cbe, .cce, .cdd: textColor = .quaternaryLabelColor
            }
            DispatchQueue.main.async {
                self.commentLabel.attributedStringValue = self.comment.text.styledAttributedString(textColor: textColor)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        replyTextView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    }

    @IBAction func reply(_ sender: NSButton) {
        let text = replyTextView.string
        guard let token = Account.selectedAccount?.token else {
            return
        }
        spinner.startAnimation(self)
        replyTextView.isEditable = false
        APIClient.shared.reply(toID: comment.id, text: text, token: token) { result in
            DispatchQueue.main.async {
                self.spinner.stopAnimation(self)
                switch result {
                case .success:
                    if self.presentingViewController != nil {
                        self.dismiss(self)
                    } else {
                        self.view.window?.close()
                    }
                case .failure(let error):
                    if self.presentingViewController != nil {
                        self.dismiss(self)
                    } else {
                        self.view.window?.close()
                    }
                    NSApplication.shared.presentError(error)
                }
            }
        }
    }

    @IBAction func cancel(_ sender: NSButton) {
        if self.presentingViewController != nil {
            self.dismiss(self)
        } else {
            self.view.window?.close()
        }
    }
}

extension ReplyPopoverViewController: NSPopoverDelegate {

    func popoverDidDetach(_ popover: NSPopover) {
        dragLabel.stringValue = "Drag here to move"
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        true
    }
}

extension NSStoryboard.SceneIdentifier {
    static var replyPopoverViewController = NSStoryboard.SceneIdentifier("ReplyPopoverViewController")
}
