
import Cocoa

@IBDesignable class ProgressView: NSView, LoadableView {

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

    // MARK: - Init

    var mainView: NSView?

    func commonInit() {
        loadFromNib()
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}
