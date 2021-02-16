
import Cocoa
import MAKAutoLayoutTextView

class CommentTextView: AutoLayoutTextView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isEditable = false
        isSelectable = true
        isHorizontalContentSizeConstraintActive = false
        drawsBackground = false
    }
}
