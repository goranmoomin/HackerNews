
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
        pageViewController.item = selectedItem
    }
}

extension MainWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.itemListTrackingSeparator]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.space, .flexibleSpace, .toggleSidebar, .itemListTrackingSeparator]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
            return NSTrackingSeparatorToolbarItem(identifier: .itemListTrackingSeparator, splitView: splitViewController.splitView, dividerIndex: 1)
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
}

extension NSToolbarItem.Identifier {
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
}
