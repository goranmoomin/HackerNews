
import Cocoa
import HNAPI

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
    var category: HNAPI.Category = .top {
        didSet {
            storiesViewController.category = category
        }
    }

    // Always in sync with it's children view controllers
    var item: TopLevelItem? {
        didSet {
            commentsViewController.item = item
        }
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
