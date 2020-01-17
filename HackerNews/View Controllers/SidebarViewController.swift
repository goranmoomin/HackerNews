
import Cocoa

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

// MARK: - SidebarHeaderCellViewDelegate

extension SidebarViewController: SidebarHeaderCellViewDelegate {

    func toggle(header: String) {
        if sidebarOutlineView.isItemExpanded(header) {
            sidebarOutlineView.collapseItem(header)
        } else {
            sidebarOutlineView.expandItem(header)
        }
    }
}

// MARK: - NSOutlineViewDataSource

extension SidebarViewController: NSOutlineViewDataSource {

    // MARK: - Static Variables

    static let sidebarItems: [Category] = [.topStories, .newStories, .bestStories, .askStories, .showStories, .jobStories]

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
        } else if let item = item as? Category {
            switch item {
            case .topStories:
                return "Top Stories"
            case .newStories:
                return "New Stories"
            case .bestStories:
                return "Best Stories"
            case .askStories:
                return "Ask Stories"
            case .showStories:
                return "Show Stories"
            case .jobStories:
                return "Job Stories"
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

    func outlineViewSelectionIsChanging(_ notification: Notification) {
        let selectedRow = sidebarOutlineView.selectedRow
        sidebarOutlineView.rowView(atRow: selectedRow, makeIfNecessary: false)?.isEmphasized = false
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = sidebarOutlineView.selectedRow
        guard selectedRow > 0 else {
            return
        }
        splitViewController.currentCategory = Self.sidebarItems[selectedRow - 1]
    }
}

// MARK: - NSUserInterfaceItemIdentifier

extension NSUserInterfaceItemIdentifier {

    static let sidebarHeaderCell = NSUserInterfaceItemIdentifier("SidebarHeaderCell")
    static let sidebarDataCell = NSUserInterfaceItemIdentifier("SidebarDataCell")
}
