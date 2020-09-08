
import Cocoa

class CommentTextView: AutoLayoutTextView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isEditable = false
        isSelectable = true
        isHorizontalContentSizeConstraintActive = false
        backgroundColor = .controlBackgroundColor
    }
}
