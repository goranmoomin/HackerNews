
import Cocoa
import HNAPI

class PageViewController: NSSplitViewController {

    var itemViewController: ItemViewController!
    var commentViewController: CommentViewController!

    var page: Page? {
        didSet {
            commentViewController.page = page
        }
    }
    var item: TopLevelItem? {
        didSet {
            itemViewController.item = item
            guard let item = item else { return }
            APIClient.shared.page(item: item, token: Account.selectedAccount?.token) { result in
                switch result {
                case .success(let page): self.page = page
                case .failure(let error):
                    DispatchQueue.main.async {
                        NSApplication.shared.presentError(error)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        itemViewController = (splitViewItems[0].viewController as! ItemViewController)
        commentViewController = (splitViewItems[1].viewController as! CommentViewController)
    }
}
