
import Cocoa
import HNAPI

class SidebarViewController: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet var sidebarOutlineView: NSOutlineView!

    // MARK: - Parent View Controller

    var splitViewController: SplitViewController {
        parent as! SplitViewController
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarOutlineView.expandItem(nil, expandChildren: true)
    }
}

// MARK: - NSOutlineViewDataSource

extension SidebarViewController: NSOutlineViewDataSource {

    // MARK: - Static Variables

    static let sidebarItems: [HNAPI.Category] = [.top, .new, .best, .ask, .show, .job]

    // MARK: - DataSource Methods

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard item != nil else {
            return "Stories"
        }
        return Self.sidebarItems[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item as? String == "Stories" {
            return true
        }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else if item as? String == "Stories" {
            return Self.sidebarItems.count
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if item is String {
            return item
        } else if let item = item as? HNAPI.Category {
            switch item {
            case .top:
                return "Top Items"
            case .new:
                return "New Items"
            case .best:
                return "Best Items"
            case .ask:
                return "Ask Items"
            case .show:
                return "Show Items"
            case .job:
                return "Job Items"
            }
        } else {
            return nil
        }
    }
}

// MARK: - NSOutlineViewDelegate

extension SidebarViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if item as? String == "Stories" {
            return false
        }
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item as? String == "Stories" {
            return outlineView.makeView(withIdentifier: .sidebarHeaderCell, owner: self)
        }
        return outlineView.makeView(withIdentifier: .sidebarDataCell, owner: self)
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        if item as? String == "Stories" {
            return true
        }
        return false
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = sidebarOutlineView.selectedRow
        guard selectedRow > 0 else {
            return
        }
        splitViewController.category = Self.sidebarItems[selectedRow - 1]
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {

    static let sidebarHeaderCell = NSUserInterfaceItemIdentifier("SidebarHeaderCell")
    static let sidebarDataCell = NSUserInterfaceItemIdentifier("SidebarDataCell")
}
