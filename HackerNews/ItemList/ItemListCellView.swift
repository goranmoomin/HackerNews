import Cocoa
import HNAPI
import SwiftUI

class ItemListCellView: NSTableCellView {

    var hostingView: NSHostingView<ItemListCellSwiftUIView>?

    override var objectValue: Any? {
        didSet {
            guard objectValue != nil else { return }
            let rootView = ItemListCellSwiftUIView(item: objectValue as! TopLevelItem)
            if let hostingView = hostingView {
                hostingView.rootView = rootView
            } else {
                let hostingView = NSHostingView(rootView: rootView)
                self.addSubview(hostingView)
                hostingView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    hostingView.topAnchor.constraint(equalTo: topAnchor),
                    hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
                self.hostingView = hostingView
            }
        }
    }
}
