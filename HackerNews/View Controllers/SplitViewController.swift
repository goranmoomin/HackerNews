
import Cocoa

class SplitViewController: NSSplitViewController {

    // MARK: - Children View Controllers

    var storiesViewController: StoriesViewController {
        children[0] as! StoriesViewController
    }

    var commentsViewController: CommentsViewController {
        children[1] as! CommentsViewController
    }

    // MARK: - Properties

    // Always in sync with it's children view controllers
    var currentStory: Story? {
        didSet {
            commentsViewController.currentStory = currentStory
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
