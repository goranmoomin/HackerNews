
import Cocoa
import HNAPI

class ItemListCellView: NSTableCellView {

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var urlButton: NSButton!
    @IBOutlet var authorGroup: NSStackView!
    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var pointsGroup: NSStackView!
    @IBOutlet var pointsLabel: NSTextField!
    @IBOutlet var commentCountGroup: NSStackView!
    @IBOutlet var commentCountLabel: NSTextField!
    @IBOutlet var creationLabel: NSTextField!

    let formatter = RelativeDateTimeFormatter()

    override var objectValue: Any? {
        didSet {
            guard objectValue != nil else {
                return
            }
            let item = objectValue as! TopLevelItem
            switch item {
            case .story(let story):
                titleLabel.stringValue = story.title
                if let host = story.content.url?.host {
                    urlButton.isHidden = false
                    urlButton.title = host
                } else {
                    urlButton.isHidden = true
                }
                authorGroup.isHidden = false
                authorLabel.stringValue = story.author
                pointsGroup.isHidden = false
                pointsLabel.stringValue = String(story.points)
                commentCountGroup.isHidden = false
                commentCountLabel.stringValue = String(story.commentCount)
                creationLabel.stringValue = formatter.localizedString(for: story.creation, relativeTo: Date())
            case .job(let job):
                titleLabel.stringValue = job.title
                if let host = job.content.url?.host {
                    urlButton.isHidden = false
                    urlButton.title = host
                } else {
                    urlButton.isHidden = true
                }
                authorGroup.isHidden = true
                pointsGroup.isHidden = true
                commentCountGroup.isHidden = true
                creationLabel.stringValue = formatter.localizedString(for: job.creation, relativeTo: Date())
            }
        }
    }
}
