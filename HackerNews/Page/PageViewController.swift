
import Cocoa
import HNAPI

class PageViewController: NSViewController {

    @IBOutlet var itemContainer: NSView!

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

    @IBSegueAction func showItemViewController(_ coder: NSCoder) -> ItemViewController? {
        let itemViewController = ItemViewController(coder: coder)
        self.itemViewController = itemViewController
        return itemViewController
    }

    @IBSegueAction func showCommentViewController(_ coder: NSCoder) -> CommentViewController? {
        let commentViewController = CommentViewController(coder: coder)
        self.commentViewController = commentViewController
        return commentViewController
    }

    var itemContainerViewConstraint: NSLayoutConstraint?

    override func updateViewConstraints() {
        if itemContainerViewConstraint == nil, let contentLayoutGuide = view.window?.contentLayoutGuide as? NSLayoutGuide {
            let contentTopAnchor = contentLayoutGuide.topAnchor
            itemContainerViewConstraint = itemContainer.topAnchor.constraint(equalTo: contentTopAnchor)
            itemContainerViewConstraint?.isActive = true
        }
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
