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

    var state: State = .none { didSet { reload() } }

    func reload() {
        switch state {
        case .none: splitView.isHidden = true
        case .item(let item):
            itemViewController.item = item
            splitView.isHidden = false
            commentViewController.page = nil
            APIClient.shared.page(item: item, token: Token.current) { result in
                guard case .item(let currentItem) = self.state, currentItem.id == item.id else {
                    return
                }
                switch result {
                case .success(let page): self.state = .page(page)
                case .failure(let error): self.state = .error(error)
                }
            }
        case .page(let page):
            DispatchQueue.main.async { self.splitView.isHidden = false }
            self.commentViewController.page = page
            self.itemViewController.page = page
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
        switch state {
        case .page(let page): state = .item(page.topLevelItem)
        default: break
        }
    }

    @objc func openInSafari(_ sender: NSToolbarItem) {
        switch state {
        case .item(let item): NSWorkspace.shared.open(item.url)
        case .page(let page): NSWorkspace.shared.open(page.topLevelItem.url)
        default: break
        }
    }
}

extension PageViewController: NSToolbarItemValidation {
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        if item.itemIdentifier == .refresh {
            switch state {
            case .page: return true
            default: return false
            }
        } else if item.itemIdentifier == .openInSafari {
            switch state {
            case .page, .item: return true
            default: return false
            }
        }
        return true
    }
}
