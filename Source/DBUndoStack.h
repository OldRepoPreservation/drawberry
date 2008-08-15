//
//  DBUndoStack.h
//  DrawBerry
//
//  Created by Raphael Bost on 23/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBUndoObject;

@interface DBUndoStack : NSObject {
	NSMutableArray *_stackObjects;
}
- (unsigned)count;
- (void)removeAllObjects;
- (void)removeAllObjectsWithTarget:(id)target;
- (void)push:(DBUndoObject *)object;
- (BOOL)popAndInvoke;
- (void)removeObject:(DBUndoObject *)object;
- (DBUndoObject *)topUndoObject;
- (DBUndoObject *)objectInStackAtIndex:(int)index;
@end
