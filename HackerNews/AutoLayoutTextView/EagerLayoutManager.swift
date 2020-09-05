// MIT License
//
// Copyright © 2016-2017 Darren Mo.
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

/// An `NSLayoutManager` subclass that performs layout immediately whenever text changes
/// or whenever the geometry of a text container changes. `EagerLayoutManager` posts a
/// `.didCompleteLayout` notification when it completes layout. The text storage must be
/// an instance of `EagerTextStorage`.
open class EagerLayoutManager: NSLayoutManager {
   // MARK: Notifications

   public static let didCompleteLayout = Notification.Name(rawValue: "mo.darren.ModernAppKit.EagerLayoutManager.didCompleteLayout")

   // MARK: Text Storage

   open override var textStorage: NSTextStorage? {
      didSet {
         if let textStorage = textStorage {
            precondition(textStorage is EagerTextStorage, "EagerLayoutManager only accepts EagerTextStorage.")
            _textStorage = textStorage as? EagerTextStorage
         }
      }
   }

   private var _textStorage: EagerTextStorage? {
      didSet {
         if _textStorage?.isEditing == false {
            performFullLayout()
         }
      }
   }

   // MARK: Initialization

   private static let textStorageCoderKey = "mo.darren.ModernAppKit.EagerLayoutManager._textStorage"

   public override init() {
      super.init()

      // Since we are performing layout eagerly, we don’t need background layout
      self.backgroundLayoutEnabled = false
   }

   public required init?(coder: NSCoder) {
      self._textStorage = coder.decodeObject(forKey: EagerLayoutManager.textStorageCoderKey) as? EagerTextStorage

      super.init(coder: coder)
   }

   open override func encode(with aCoder: NSCoder) {
      super.encode(with: aCoder)

      aCoder.encode(self._textStorage, forKey: EagerLayoutManager.textStorageCoderKey)
   }

   // MARK: Performing Layout

   open override func textContainerChangedGeometry(_ container: NSTextContainer) {
      super.textContainerChangedGeometry(container)

      if _textStorage?.isEditing == false {
         performFullLayout()
      }
   }

   @objc
   open func performFullLayout() {
      guard let textStorage = _textStorage else {
         return
      }
      guard !textStorage.isEditing else {
         return
      }

      ensureLayout(forCharacterRange: NSRange(location: 0, length: textStorage.length))

      NotificationCenter.default.post(name: EagerLayoutManager.didCompleteLayout,
                                      object: self)
   }
}
