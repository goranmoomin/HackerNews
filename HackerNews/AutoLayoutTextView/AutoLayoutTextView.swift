// MIT License
//
// Copyright © 2016-2019 Darren Mo.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

/// An `NSTextView` subclass that implements `intrinsicContentSize` so that the text view
/// can participate in layout outside of a scroll view.
open class AutoLayoutTextView: NSTextView {
   // MARK: Text Components

   private var _textStorage: EagerTextStorage?
   open override var textStorage: NSTextStorage? {
      return _textStorage
   }

   private var _layoutManager: EagerLayoutManager?
   open override var layoutManager: NSLayoutManager? {
      return _layoutManager
   }

   /// Text container for the text view.
   ///
   /// The text view will use the text storage and layout manager associated with the specified
   /// text container. The text storage and layout manager must be instances of
   /// `EagerTextStorage` and `EagerLayoutManager`, respectively.
   open override var textContainer: NSTextContainer? {
      willSet {
         if let layoutManager = _layoutManager {
            NotificationCenter.default.removeObserver(self,
                                                      name: EagerLayoutManager.didCompleteLayout,
                                                      object: layoutManager)
         }
      }

      didSet {
         if let textContainer = textContainer {
            if let layoutManager = textContainer.layoutManager {
               precondition(layoutManager is EagerLayoutManager, "AutoLayoutTextView requires the layout manager to be an instance of EagerLayoutManager.")
               self._layoutManager = layoutManager as? EagerLayoutManager

               if let textStorage = layoutManager.textStorage {
                  precondition(textStorage is EagerTextStorage, "AutoLayoutTextView requires the text storage to be an instance of EagerTextStorage.")
                  self._textStorage = textStorage as? EagerTextStorage
               }
            }
         }

         if let layoutManager = _layoutManager {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didCompleteLayout(_:)),
                                                   name: EagerLayoutManager.didCompleteLayout,
                                                   object: layoutManager)
         }
      }
   }

   // MARK: Initialization

   private static let textStorageCoderKey = "mo.darren.ModernAppKit.AutoLayoutTextView._textStorage"
   private static let layoutManagerCoderKey = "mo.darren.ModernAppKit.AutoLayoutTextView._layoutManager"

   public override convenience init(frame frameRect: NSRect) {
      let textContainer = AutoLayoutTextView.makeDefaultTextContainer(withTextViewWidth: frameRect.width)

      let layoutManager = EagerLayoutManager()
      layoutManager.addTextContainer(textContainer)

      let textStorage = EagerTextStorage()
      textStorage.addLayoutManager(layoutManager)

      self.init(frame: frameRect, textContainer: textContainer)
   }

   public override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
      if let textContainer = container {
         if let layoutManager = textContainer.layoutManager {
            precondition(layoutManager is EagerLayoutManager, "AutoLayoutTextView requires the layout manager to be an instance of EagerLayoutManager.")
            self._layoutManager = layoutManager as? EagerLayoutManager

            if let textStorage = layoutManager.textStorage {
               precondition(textStorage is EagerTextStorage, "AutoLayoutTextView requires the text storage to be an instance of EagerTextStorage.")
               self._textStorage = textStorage as? EagerTextStorage
            }
         }
      }

      super.init(frame: frameRect, textContainer: container)

      commonInit()
   }

   public required init?(coder: NSCoder) {
      if let textStorage = coder.decodeObject(forKey: AutoLayoutTextView.textStorageCoderKey) as? EagerTextStorage {
         self._textStorage = textStorage
      } else {
         self._textStorage = EagerTextStorage()
      }
      if let layoutManager = coder.decodeObject(forKey: AutoLayoutTextView.layoutManagerCoderKey) as? EagerLayoutManager {
         self._layoutManager = layoutManager
      } else {
         self._layoutManager = EagerLayoutManager()
      }

      super.init(coder: coder)

      if let layoutManager = _layoutManager {
         _textStorage?.addLayoutManager(layoutManager)

         if let textContainer = textContainer {
            layoutManager.addTextContainer(textContainer)
         } else {
            let textContainer = AutoLayoutTextView.makeDefaultTextContainer(withTextViewWidth: frame.width)
            layoutManager.addTextContainer(textContainer)

            textContainer.textView = self
            self.textContainer = textContainer
         }
      }

      commonInit()
   }

   private func commonInit() {
      minSize = NSSize.zero
      maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
      isHorizontallyResizable = false
      isVerticallyResizable = false

      if let layoutManager = _layoutManager {
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(didCompleteLayout(_:)),
                                                name: EagerLayoutManager.didCompleteLayout,
                                                object: layoutManager)
      }
   }

   open override func encode(with aCoder: NSCoder) {
      super.encode(with: aCoder)

      aCoder.encode(_textStorage, forKey: AutoLayoutTextView.textStorageCoderKey)
      aCoder.encode(_layoutManager, forKey: AutoLayoutTextView.layoutManagerCoderKey)
   }

   deinit {
      if let layoutManager = _layoutManager {
         // Because NSTextView does not support weak references, NotificationCenter will not
         // automatically remove the observer for us.
         NotificationCenter.default.removeObserver(self,
                                                   name: EagerLayoutManager.didCompleteLayout,
                                                   object: layoutManager)
      }
   }

   private static func makeDefaultTextContainer(withTextViewWidth textViewWidth: CGFloat) -> NSTextContainer {
      let textContainer = NSTextContainer(size: NSSize(width: textViewWidth, height: CGFloat.infinity))
      textContainer.widthTracksTextView = true
      textContainer.heightTracksTextView = false
      textContainer.lineFragmentPadding = 0

      return textContainer
   }

   // MARK: Intrinsic Content Size

   /// Called when the layout manager completes layout.
   ///
   /// The default implementation of this method invalidates the intrinsic content size.
   @objc
   open func didCompleteLayout(_ notification: Notification) {
      invalidateIntrinsicContentSize()
   }

   open override func invalidateIntrinsicContentSize() {
      _intrinsicContentSize = nil
      super.invalidateIntrinsicContentSize()
   }

   private var _intrinsicContentSize: NSSize?
   open override var intrinsicContentSize: NSSize {
      if let intrinsicContentSize = _intrinsicContentSize {
         return intrinsicContentSize
      } else {
         let intrinsicContentSize = calculateIntrinsicContentSize()
         _intrinsicContentSize = intrinsicContentSize
         return intrinsicContentSize
      }
   }

   private func calculateIntrinsicContentSize() -> NSSize {
      guard let layoutManager = layoutManager, let textContainer = textContainer else {
         return NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
      }

      let textHeight = layoutManager.usedRect(for: textContainer).height

      // The layout manager’s `usedRect(for:)` method returns (width of container, height of text).
      // We want to use the width of the text for the intrinsic content size, so we need to calculate
      // it ourselves.
      let textWidth = calculateTextWidth()

      let unitSquareSize = self.unitSquareSize

      let intrinsicContentWidth =
         (textWidth + textContainerInset.width * 2) * unitSquareSize.width
      let intrinsicContentHeight =
         (textHeight + textContainerInset.height * 2) * unitSquareSize.height

      return NSSize(width: intrinsicContentWidth.rounded(.up),
                    height: intrinsicContentHeight.rounded(.up))
   }

   /// Calculates the width of the text by unioning all the line fragment used rects.
   private func calculateTextWidth() -> CGFloat {
      guard let layoutManager = layoutManager, let textContainer = textContainer else {
         return NSView.noIntrinsicMetric
      }

      var enclosingRect: NSRect?

      let extraLineFragmentUsedRect = layoutManager.extraLineFragmentUsedRect
      if extraLineFragmentUsedRect.size != NSSize.zero {
         enclosingRect = extraLineFragmentUsedRect
      }

      let glyphRange = layoutManager.glyphRange(for: textContainer)
      layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, lineFragmentUsedRect, _, _, _ in
         if let previousEnclosingRect = enclosingRect {
            enclosingRect = previousEnclosingRect.union(lineFragmentUsedRect)
         } else {
            enclosingRect = lineFragmentUsedRect
         }
      }

      return enclosingRect?.width ?? 0
   }

   // MARK: Responding to Scale Changes

   private var unitSquareSize: NSSize {
      return NSSize(width: AutoLayoutTextView.calculateUnitSquareLength(frameLength: frame.width,
                                                                        boundsLength: bounds.width),
                    height: AutoLayoutTextView.calculateUnitSquareLength(frameLength: frame.height,
                                                                         boundsLength: bounds.height))
   }

   private static func calculateUnitSquareLength(frameLength: CGFloat,
                                                 boundsLength: CGFloat) -> CGFloat {
      let unitSquareLength = frameLength / boundsLength
      guard unitSquareLength != 0 && unitSquareLength.isFinite else {
         return 1
      }

      return unitSquareLength
   }

   open override func scaleUnitSquare(to newUnitSize: NSSize) {
      // The `scaleUnitSquare(to:)` method is poorly named (rdar://45887722). Rather than
      // replacing the current view scale with the new scale, it multiplies the new scale to the
      // current view scale.
      //
      // Since the former behavior is the most intuitive based on the method name, we change the
      // behavior to the former by resetting the scale to 1 before calling the NSView implementation.
      setBoundsSize(frame.size)

      super.scaleUnitSquare(to: newUnitSize)
   }
}
