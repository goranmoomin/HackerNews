// MIT License
//
// Copyright © 2017-2018 Darren Mo.
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

@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

APPKIT_EXTERN NSNotificationName const EagerTextStorageWillChangeNotification NS_SWIFT_NAME(EagerTextStorage.willChange);
APPKIT_EXTERN NSNotificationName const EagerTextStorageDidChangeNotification NS_SWIFT_NAME(EagerTextStorage.didChange);

/// A concrete `NSTextStorage` subclass that tells its `EagerLayoutManager` objects to
/// perform layout after every edit.
///
/// - Note: This is implemented in Objective-C to avoid bridging costs to/from Swift. This
///   improves text layout performance dramatically compared to the Swift implementation.
@interface EagerTextStorage : NSTextStorage

@property (readonly, nonatomic) BOOL isEditing;

@end

NS_ASSUME_NONNULL_END
