
import Cocoa
import PromiseKit

class StoriesViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var storyTableView: NSTableView!
    @IBOutlet var progressBar: NSProgressIndicator!

    // MARK: - Properties

    var splitViewController: SplitViewController {
        parent as! SplitViewController
    }

    var stories: [Storyable] = [] {
        didSet {
            storyTableView.reloadData()
        }
    }

    var selectedStory: Story? {
        get {
            splitViewController.currentStory
        }
        set {
            splitViewController.currentStory = newValue
        }
    }

    var storyLoadProgress: Progress? {
        didSet {
            observation = storyLoadProgress?.observe(\.fractionCompleted) { progress, _ in
                self.progressBar.doubleValue = progress.fractionCompleted
            }
        }
    }
    var observation: NSKeyValueObservation?

    // MARK: - Methods

    func loadAndDisplayStories() {
        progressBar.doubleValue = 0
        storyTableView.isHidden = true
        progressBar.isHidden = false

        storyLoadProgress = Progress(totalUnitCount: 100)
        storyLoadProgress?.becomeCurrent(withPendingUnitCount: 100)
        firstly {
            HackerNewsAPI.topStories(count: 10)
        }.done { stories in
            self.storyLoadProgress?.resignCurrent()
            self.storyLoadProgress = nil
            self.progressBar.isHidden = true
            self.progressBar.doubleValue = 0
            self.stories = stories
            self.storyTableView.reloadData()
            self.storyTableView.isHidden = false
        }.catch { error in
            print(error)
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAndDisplayStories()
    }
}

// MARK: - StoryCellViewDelegate

extension StoriesViewController: StoryCellViewDelegate {

    func formattedTitle(for story: Storyable?) -> String {
        guard let story = story else {
            return ""
        }
        return story.title
    }

    func formattedScore(for story: Storyable?) -> String {
        guard let story = story, !(story is Job) else {
            return ""
        }
        return String(story.score)
    }

    func formattedCommentCount(for story: Storyable?) -> String {
        guard let story = story as? Story else {
            return ""
        }
        return String(story.commentCount)
    }

    func isURLHidden(for story: Storyable?) -> Bool {
        guard let story = story as? Story else {
            return true
        }
        return story.url == nil
    }

    func formattedURL(for story: Storyable?) -> String {
        guard let story = story as? Story, let urlHost = story.url?.host else {
            return ""
        }
        return urlHost
    }

    func openURL(for story: Storyable?) {
        guard let story = story as? Story, let url = story.url else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

// MARK: - NSTableViewDataSource

extension StoriesViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        stories.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        stories[row]
    }
}

// MARK: - NSTableViewDelegate
extension StoriesViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // objectValue is automatically populated
        tableView.makeView(withIdentifier: .storyCellView, owner: self)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedStory = stories[storyTableView.selectedRow] as? Story
    }
}

// MARK: - NSUserInterfaceItemIdentifier
extension NSUserInterfaceItemIdentifier {
    static let storyCellView = NSUserInterfaceItemIdentifier("StoryCellView")
}
