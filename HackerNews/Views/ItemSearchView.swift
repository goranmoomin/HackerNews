
import Cocoa

protocol ItemSearchViewDelegate {

    func searchItems(matching query: String)
    func reloadItems(count: Int)
}

class ItemSearchView: NSView {

    // MARK: - IBOutlets

    @IBOutlet var itemSearchField: NSSearchField!
    @IBOutlet var itemCountPopUp: NSPopUpButton!

    // MARK: - Delegate

    var delegate: ItemSearchViewDelegate?

    // MARK: - IBAction

    @IBAction func reloadItems(_ sender: NSPopUpButton) {
        guard let delegate = delegate, let selectedItem = itemCountPopUp.selectedItem else {
            return
        }
        let count = Int(selectedItem.title)!
        delegate.reloadItems(count: count)
    }

    @IBAction func searchItems(_ sender: NSSearchField) {
        guard let delegate = delegate else {
            return
        }
        let query = itemSearchField.stringValue
        delegate.searchItems(matching: query)
    }
}
