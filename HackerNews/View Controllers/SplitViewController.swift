
import Cocoa
import HackerNewsAPI

class SplitViewController: NSSplitViewController {

    // MARK: - Children View Controllers

    var sidebarViewController: SidebarViewController {
        children[0] as! SidebarViewController
    }

    var storiesViewController: ItemsViewController {
        children[1] as! ItemsViewController
    }

    var commentsViewController: CommentsViewController {
        children[2] as! CommentsViewController
    }

    // MARK: - Properties

    // Always in sync with it's children view controllers
    var currentCategory: ItemListCategory = .top {
        didSet {
            storiesViewController.currentCategory = currentCategory
        }
    }

    // Always in sync with it's children view controllers
    var currentItem: ListableItem? {
        didSet {
            commentsViewController.currentItem = currentItem
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
