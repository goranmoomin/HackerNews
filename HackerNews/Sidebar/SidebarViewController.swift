import Cocoa
import HNAPI

protocol SidebarDelegate {
    func sidebarSelectionDidChange(
        _ sidebarViewController: SidebarViewController, selectedCategory: HNAPI.Category)
}

class SidebarViewController: NSViewController {

    @IBOutlet var sidebarOutlineView: NSOutlineView!

    var delegate: SidebarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarOutlineView.expandItem(nil, expandChildren: true)
        sidebarOutlineView.selectRowIndexes(IndexSet([1]), byExtendingSelection: false)
    }
}

extension SidebarViewController: NSOutlineViewDataSource {

    static let categories: [HNAPI.Category] = [.top, .new, .best, .ask, .show, .job]

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard item != nil else { return SidebarItem.header(title: "Categories") }
        guard case let .header(title: title) = item as! SidebarItem, title == "Categories" else {
            fatalError()
        }
        return SidebarItem.category(Self.categories[index])
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let item = item as! SidebarItem
        switch item {
        case .header: return true
        case .category: return false
        }
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard item != nil else { return 1 }
        let item = item as! SidebarItem
        switch item {
        case let .header(title: title):
            guard title == "Categories" else { fatalError() }
            return Self.categories.count
        case .category: return 0
        }
    }

    func outlineView(
        _ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?
    ) -> Any? { item }
}

extension SidebarViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any)
        -> NSView?
    {
        let item = item as! SidebarItem
        switch item {
        case .header: return outlineView.makeView(withIdentifier: .sidebarHeaderCell, owner: self)
        case .category: return outlineView.makeView(withIdentifier: .sidebarDataCell, owner: self)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        let item = item as! SidebarItem
        switch item {
        case .header: return true
        case .category: return false
        }
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        let item = item as! SidebarItem
        switch item {
        case .header: return false
        case .category: return true
        }
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard sidebarOutlineView.selectedRow > 0 else { return }
        delegate?
            .sidebarSelectionDidChange(
                self, selectedCategory: Self.categories[sidebarOutlineView.selectedRow - 1])
    }
}

extension NSUserInterfaceItemIdentifier {
    static let sidebarHeaderCell = NSUserInterfaceItemIdentifier("SidebarHeaderCell")
    static let sidebarDataCell = NSUserInterfaceItemIdentifier("SidebarDataCell")
}
