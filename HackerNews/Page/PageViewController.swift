
import Cocoa
import HNAPI

class PageViewController: NSSplitViewController {

    enum State {
        case item(TopLevelItem)
        case page(Page)
        case error(Error)
        case none
    }

    var itemViewController: ItemViewController!
    var commentViewController: CommentViewController!

    var state: State = .none {
        didSet {
            reload()
        }
    }

    func reload() {
        switch state {
        case .none:
            splitView.isHidden = true
        case .item(let item):
            itemViewController.item = item
            splitView.isHidden = false
            APIClient.shared.page(item: item, token: Account.selectedAccount?.token) { result in
                DispatchQueue.main.async {
                    self.commentViewController.view.isHidden = false
                }
                switch result {
                case .success(let page): self.state = .page(page)
                case .failure(let error): self.state = .error(error)
                }
            }
        case .page(let page):
            DispatchQueue.main.async {
                self.splitView.isHidden = false
                self.commentViewController.page = page
                self.itemViewController.page = page
            }
        case .error(let error):
            DispatchQueue.main.async {
                self.splitView.isHidden = false
                NSApplication.shared.presentError(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        itemViewController = (splitViewItems[0].viewController as! ItemViewController)
        commentViewController = (splitViewItems[1].viewController as! CommentViewController)
        state = .none
    }

    @objc func refresh(_ sender: NSToolbarItem) {
        reload()
    }
}

extension PageViewController: NSToolbarItemValidation {
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        if item.itemIdentifier == .refresh {
            switch state {
            case .none: return false
            default: return true
            }
        }
        return true
    }
}
