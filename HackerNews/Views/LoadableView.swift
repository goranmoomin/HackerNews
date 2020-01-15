
import Cocoa

protocol LoadableView: class {
    var viewNibName: NSNib.Name { get }
    var mainView: NSView? { get set }

    func loadFromNib()
}

extension LoadableView where Self: NSView {

    var viewNibName: NSNib.Name {
        NSNib.Name(String(describing: Self.self))
    }

    func loadFromNib() {
        var nibObjects: NSArray?

        guard Bundle.main.loadNibNamed(viewNibName, owner: self, topLevelObjects: &nibObjects) else {
            return
        }

        guard nibObjects != nil else { return }
        let viewObjects = nibObjects!.filter { $0 is NSView }

        if viewObjects.count > 0 {
            guard let view = viewObjects[0] as? NSView else { return }
            mainView = view
            self.addSubview(mainView!)

            mainView?.translatesAutoresizingMaskIntoConstraints = false
            mainView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            mainView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            mainView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            mainView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

            return
        }
    }
}
