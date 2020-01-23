
import Cocoa

protocol SidebarHeaderCellViewDelegate {

    func toggle(header: String)
}

class SidebarHeaderCellView: NSTableCellView {

    // MARK: - IBOutlets

    @IBOutlet var headerLabel: NSTextField!
    @IBOutlet var disclosureButton: NSButton!

    // MARK: - Delegate

    var delegate: SidebarHeaderCellViewDelegate?

    // MARK: - Properties

    override var objectValue: Any? {
        didSet {
            updateInterface()
        }
    }

    var headerText: String? {
        objectValue as? String
    }

    // MARK: - IBActions

    @IBAction func disclosureButton(_ sender: NSButton) {
        guard let headerText = headerText else {
            return
        }
        delegate?.toggle(header: headerText)
    }

    // MARK: - Methods

    func updateInterface() {
        guard let headerText = headerText else {
            return
        }
        headerLabel.stringValue = headerText
    }

    // MARK: - Overrides

    override func mouseEntered(with event: NSEvent) {
        disclosureButton.isHidden = false
    }

    override func mouseExited(with event: NSEvent) {
        disclosureButton.isHidden = true
    }

    // MARK: - Init

    func commonInit() {
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
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
