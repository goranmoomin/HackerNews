
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
    var stories: [Storyable] = [] {
        didSet {
            storiesViewController.stories = stories
        }
    }

    // Always in sync with it's children view controllers
    var currentStory: Story? {
        didSet {
            commentsViewController.currentStory = currentStory
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        HackerNewsAPI.firebaseTopStories(count: 10).done { stories in
            self.stories = stories
        }.catch { error in
            print(error)
        }
    }
}
