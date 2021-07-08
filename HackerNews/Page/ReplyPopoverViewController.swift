import Cocoa
import HNAPI

protocol ReplyPopoverViewControllerDelegate {
    func replyDidSubmit(_ replyPopoverViewController: ReplyPopoverViewController)
    func replyDidCancel(_ replyPopoverViewController: ReplyPopoverViewController)
}

class ReplyPopoverViewController: NSViewController {

    @IBOutlet var commentTextView: CommentTextView?
    @IBOutlet var replyTextView: NSTextView!
    @IBOutlet var spinner: NSProgressIndicator!

    @IBOutlet var insertItalicsButton: NSButton!
    @IBOutlet var insertLinkButton: NSButton!
    @IBOutlet var insertCodeButton: NSButton!

    var delegate: ReplyPopoverViewControllerDelegate?

    var commentable: Commentable! {
        didSet {
            guard let comment = commentable as? Comment else { return }
            let textColor: NSColor
            switch comment.color {
            case .c00: textColor = .labelColor
            case .c5a, .c73, .c82: textColor = .secondaryLabelColor
            case .c88, .c9c, .cae: textColor = .tertiaryLabelColor
            case .cbe, .cce, .cdd: textColor = .quaternaryLabelColor
            }
            DispatchQueue.main.async {
                self.commentTextView?.textStorage?
                    .setAttributedString(comment.text.styledAttributedString(textColor: textColor))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        replyTextView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    }

    @IBAction func reply(_ sender: NSButton) {
        let text = replyTextView.string
        guard let token = Account.selectedAccount?.token else { return }
        spinner.startAnimation(self)
        replyTextView.isEditable = false
        APIClient.shared.reply(to: commentable, text: text, token: token) { result in
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
                self.delegate?.replyDidSubmit(self)
            }
        }
    }

    @IBAction func cancel(_ sender: NSButton) {
        if self.presentingViewController != nil {
            self.dismiss(self)
        } else {
            self.view.window?.close()
        }
        self.delegate?.replyDidCancel(self)
    }

    var linkNumber = 0

    @IBAction func insertMarkup(_ sender: NSButton) {
        replyTextView.undoManager?.beginUndoGrouping()
        let selectedRange = replyTextView.selectedRange()
        if sender == insertItalicsButton {
            replyTextView.insertText("**", replacementRange: selectedRange)
            replyTextView.moveLeft(self)
        } else if sender == insertCodeButton {
            // FIXME: This doesn't work in wrapped lines
            // TODO: Prompt for user input
            replyTextView.moveToBeginningOfLine(self)
            replyTextView.insertText("  ", replacementRange: replyTextView.selectedRange())
        } else if sender == insertLinkButton {
            // TODO: Detect numbers instead of incrementing
            replyTextView.insertText("[\(linkNumber)]", replacementRange: selectedRange)
            replyTextView.moveToEndOfDocument(self)
            replyTextView.insertNewline(self)
            replyTextView.insertText(
                "[\(linkNumber)]: ", replacementRange: replyTextView.selectedRange())
            linkNumber += 1
        }
        replyTextView.undoManager?.endUndoGrouping()
    }
}

extension ReplyPopoverViewController: NSPopoverDelegate {
    func popoverShouldDetach(_ popover: NSPopover) -> Bool { true }
}

extension NSStoryboard.SceneIdentifier {
    static var commentReplyPopoverViewController = NSStoryboard.SceneIdentifier(
        "CommentReplyPopoverViewController")
    static var itemReplyPopoverViewController = NSStoryboard.SceneIdentifier(
        "ItemReplyPopoverViewController")
}
