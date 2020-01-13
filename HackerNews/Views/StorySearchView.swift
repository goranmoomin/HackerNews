
import Cocoa

@objc protocol StorySearchViewDelegate {

    func reloadStories(count: Int)
}

class StorySearchView: NSView {

    // MARK: - IBOutlets

    @IBOutlet var storySearchField: NSSearchField!
    @IBOutlet var storyCountPopUp: NSPopUpButton!

    // MARK: - Delegate

    @IBOutlet var delegate: StorySearchViewDelegate?

    // MARK: - IBAction

    @IBAction func reloadStories(_ sender: NSPopUpButton) {
        guard let delegate = delegate, let selectedItem = storyCountPopUp.selectedItem else {
            return
        }
        let count = Int(selectedItem.title)!
        delegate.reloadStories(count: count)
    }
}
