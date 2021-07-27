import Cocoa

class MainSplitViewController: NSSplitViewController {

    override func moveLeft(_ sender: Any?) { changeSelectedSplitViewItemIndex(by: -1) }

    override func moveRight(_ sender: Any?) { changeSelectedSplitViewItemIndex(by: 1) }

    func changeSelectedSplitViewItemIndex(by offset: Int) {
        guard let firstResponder = view.window?.firstResponder as? NSView,
            let currentIndex = splitViewItemIndex(of: firstResponder),
            (0..<splitViewItems.count).contains(currentIndex + offset)
        else {
            NSSound.beep()
            return
        }
        selectSplitViewItem(at: currentIndex + offset)
    }

    func selectSplitViewItem(at index: Int) {
        precondition((0..<splitViewItems.count).contains(index))
        // VCs might have a better idea of which view should become first responder
        view.window?
            .makeFirstResponder(
                splitViewItems[index].viewController.view.firstSubview(ofType: NSTableView.self))
    }

    func splitViewItemIndex(of subview: NSView) -> Int? {
        for (idx, item) in splitViewItems.enumerated() {
            if subview.isDescendant(of: item.viewController.view) { return idx }
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()  // Do view setup here.
    }
}
