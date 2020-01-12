
import Cocoa

class ProgressView: NSView {

    // MARK: - IBOutlets

    @IBOutlet var label: NSTextField!
    @IBOutlet var progressBar: NSProgressIndicator!

    // MARK: - Properties

    var observation: NSKeyValueObservation?

    var progress: Progress? {
        didSet {
            updateInterface()
        }
    }

    var labelText: String = "" {
        didSet {
            label.stringValue = labelText
        }
    }

    // MARK: - Methods

    func updateInterface() {
        guard let progress = progress else {
            observation = nil
            self.isHidden = true
            return
        }
        observation = progress.observe(\.fractionCompleted) { progress, _ in
            self.progressBar.doubleValue = progress.fractionCompleted
        }
        progressBar.doubleValue = 0
        self.isHidden = false
    }
}
