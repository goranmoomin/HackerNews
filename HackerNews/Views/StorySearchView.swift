
import Cocoa

protocol StorySearchViewDelegate {

    func searchStories(matching query: String)
    func reloadStories(count: Int)
}

class StorySearchView: NSView {

    // MARK: - IBOutlets

    @IBOutlet var storySearchField: NSSearchField!
    @IBOutlet var storyCountPopUp: NSPopUpButton!

    // MARK: - Delegate

    var delegate: StorySearchViewDelegate?

    // MARK: - IBAction

    @IBAction func reloadStories(_ sender: NSPopUpButton) {
        guard let delegate = delegate, let selectedItem = storyCountPopUp.selectedItem else {
            return
        }
        let count = Int(selectedItem.title)!
        delegate.reloadStories(count: count)
    }

    @IBAction func searchStories(_ sender: NSSearchField) {
        guard let delegate = delegate else {
            return
        }
        let query = storySearchField.stringValue
        delegate.searchStories(matching: query)
    }
}
