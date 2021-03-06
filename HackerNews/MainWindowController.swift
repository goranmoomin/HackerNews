
import Cocoa
import HNAPI

class MainWindowController: NSWindowController {

    var splitViewController: NSSplitViewController {
        contentViewController as! NSSplitViewController
    }

    var sidebarViewController: SidebarViewController {
        splitViewController.splitViewItems[0].viewController as! SidebarViewController
    }

    var itemListViewController: ItemListViewController {
        splitViewController.splitViewItems[1].viewController as! ItemListViewController
    }

    var pageViewController: PageViewController {
        splitViewController.splitViewItems[2].viewController as! PageViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        sidebarViewController.delegate = self
        itemListViewController.delegate = self
    }
}

extension MainWindowController: SidebarDelegate {
    func sidebarSelectionDidChange(_ sidebarViewController: SidebarViewController, selectedCategory: HNAPI.Category) {
        if itemListViewController.category != selectedCategory {
            itemListViewController.category = selectedCategory
        }
    }
}

extension MainWindowController: ItemListViewControllerDelegate {
    func itemListSelectionDidChange(_ itemListViewController: ItemListViewController, selectedItem: TopLevelItem) {
        pageViewController.state = .item(selectedItem)
    }
}

extension MainWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.search, .itemListTrackingSeparator, .flexibleSpace, .openInSafari, .refresh]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.space, .flexibleSpace, .toggleSidebar, .search, .itemListTrackingSeparator, .refresh, .openInSafari]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
            return NSTrackingSeparatorToolbarItem(identifier: .itemListTrackingSeparator, splitView: splitViewController.splitView, dividerIndex: 1)
        case .search:
            return NSSearchToolbarItem(itemIdentifier: .search)
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    func toolbarWillAddItem(_ notification: Notification) {
        let item = notification.userInfo?["item"] as! NSToolbarItem
        if item.itemIdentifier == .search {
            let searchItem = item as! NSSearchToolbarItem
            searchItem.searchField.target = itemListViewController
            searchItem.searchField.action = #selector(ItemListViewController.search(_:))
        } else if item.itemIdentifier == .refresh {
            item.isBordered = true
            item.image = NSImage(named: "NSRefreshTemplate")
            item.target = pageViewController
            item.action = #selector(PageViewController.refresh(_:))
        } else if item.itemIdentifier == .openInSafari {
            item.isBordered = true
            item.image = NSImage(systemSymbolName: "safari", accessibilityDescription: "Open in Safari")
            item.target = pageViewController
            item.action = #selector(PageViewController.openInSafari(_:))
        }
    }
}

extension NSToolbarItem.Identifier {
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let search = NSToolbarItem.Identifier("Search")
    static let refresh = NSToolbarItem.Identifier("Refresh")
    static let openInSafari = NSToolbarItem.Identifier("OpenInSafari")
}
