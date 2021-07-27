import Cocoa

extension NSView {
    func firstSubview<T: NSView>(ofType type: T.Type) -> T? {
        for sub in self.subviews {
            if let v = self as? T { return v }
            if let v = sub.firstSubview(ofType: type) { return v }
        }
        return nil
    }
}
