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

    var state: State = .none { didSet { Task { await reloadData() } } }

    func reloadData() async {
        switch state {
        case .none: Task { splitView.isHidden = true }
        case .item(let item):
            Task {
                itemViewController.item = item
                splitView.isHidden = false
                commentViewController.page = nil
            }
            do {
                let page = try await APIClient.shared.page(item: item, token: Token.current)
                guard case .item(let currentItem) = self.state, currentItem.id == item.id else {
                    return
                }
                self.state = .page(page)
            } catch let error { self.state = .error(error) }
        case .page(let page):
            Task { self.splitView.isHidden = false }
            self.commentViewController.page = page
            self.itemViewController.page = page
        case .error(let error):
            Task {
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

    @objc func refresh(_ sender: Any) {
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
