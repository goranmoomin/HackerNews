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

#import "EagerTextStorage.h"

#import <HackerNews-Swift.h>

// MARK: Notifications

NSNotificationName const EagerTextStorageWillChangeNotification = @"mo.darren.ModernAppKit.EagerTextStorage.willChange";
NSNotificationName const EagerTextStorageDidChangeNotification = @"mo.darren.ModernAppKit.EagerTextStorage.didChange";

// MARK: Backing Store

/// We use NSTextStorage as the backing store for two reasons.
///
/// (1) NSTextStorage might use some special, performant backing store. We want to use that.
///
/// (2) The `string` property getter could be called a lot from Swift code. The NSString object
///     returned by `_backingStore.string` needs to be bridged to String. This involves
///     a CFStringCreateCopy. If the backing store is an NSConcreteMutableAttributedString,
///     which uses __NSCFString, then the copy is O(n). If the backing store is an
///     NSConcreteTextStorage, which uses NSConcreteNotifyingMutableAttributedString, which
///     uses NSBigMutableString, then the copy is O(1).
#define EagerTextStorageBackingStoreClass ([NSTextStorage class])

// MARK: -

@implementation EagerTextStorage {
   NSMutableAttributedString *_backingStore;

   NSInteger _editingCount;
}

// MARK: Nested Editing State

- (BOOL)isEditing {
   return _editingCount > 0;
}

// MARK: Initialization

- (instancetype)init {
   self = [super init];

   if (self) {
      _backingStore = [[EagerTextStorageBackingStoreClass alloc] init];
   }

   return self;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type {
   self = [super initWithPasteboardPropertyList:propertyList ofType:type];

   if (self) {
      _backingStore = [[EagerTextStorageBackingStoreClass alloc] init];
   }

   return self;
}

static NSString *const EagerTextStorageBackingStoreCoderKey = @"mo.darren.ModernAppKit.EagerTextStorage._backingStore";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
   self = [super initWithCoder:aDecoder];

   if (self) {
      _backingStore = [aDecoder decodeObjectForKey:EagerTextStorageBackingStoreCoderKey];
   }

   return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
   [super encodeWithCoder:aCoder];

   [aCoder encodeObject:_backingStore forKey:EagerTextStorageBackingStoreCoderKey];
}

// MARK: Custom Change Notifications

- (void)beginEditing {
   if (!self.isEditing) {
      [self willBeginEditing];
   }

   _editingCount += 1;

   [super beginEditing];
   [_backingStore beginEditing];
}

- (void)edited:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
   [super edited:editedMask range:editedRange changeInLength:delta];

   if (!self.isEditing) {
      [self didEndEditing];
   }
}

- (void)endEditing {
   [_backingStore endEditing];
   [super endEditing];

   _editingCount -= 1;

   if (!self.isEditing) {
      [self didEndEditing];
   }
}

- (void)willBeginEditing {
   [[NSNotificationCenter defaultCenter] postNotificationName:EagerTextStorageWillChangeNotification
                                                       object:self];
}

- (void)didEndEditing {
   [self performFullLayout];

   [[NSNotificationCenter defaultCenter] postNotificationName:EagerTextStorageDidChangeNotification
                                                       object:self];
}

- (void)performFullLayout {
   for (NSLayoutManager *layoutManager in self.layoutManagers) {
      if ([layoutManager isKindOfClass:[EagerLayoutManager class]]) {
         EagerLayoutManager *eagerLayoutManager = (EagerLayoutManager *)layoutManager;
         [eagerLayoutManager performFullLayout];
      }
   }
}

// MARK: NSMutableAttributedString Primitives

- (NSString *)string {
   return _backingStore.string;
}

- (NSDictionary<NSAttributedStringKey,id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
   return [_backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
   if (!self.isEditing) {
      [self willBeginEditing];
   }

   [_backingStore replaceCharactersInRange:range withString:str];
   [self edited:NSTextStorageEditedCharacters range:range changeInLength:(str.length - range.length)];
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attrs range:(NSRange)range {
   if (!self.isEditing) {
      [self willBeginEditing];
   }

   [_backingStore setAttributes:attrs range:range];
   [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
