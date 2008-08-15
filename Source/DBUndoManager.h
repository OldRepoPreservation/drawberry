//
//  DBUndoManager.h
//  DrawBerry
//
//  Created by Raphael Bost on 23/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBUndoStack,DBUndoObject;

extern NSString *DBUndoManagerWillUndoChangeNotification;
extern NSString *DBUndoManagerWillRedoChangeNotification;
extern NSString *DBUndoManagerDidUndoChangeNotification;
extern NSString *DBUndoManagerDidRedoChangeNotification;
extern NSString *DBUndoManagerUndoActionsDidChange;
extern NSString *DBUndoManagerUndoActionsWillChange;

@interface DBUndoManager : NSObject {
	DBUndoStack *_undoStack;
	DBUndoStack *_redoStack;
	
	id _preparedInvocationTarget;
	
	struct {
        unsigned int undoing:1;
        unsigned int redoing:1;
        unsigned int registeredForCallback:1;
        unsigned int postingCheckpointNotification:1;
        unsigned int groupsByEvent:1;
        unsigned int reserved:27;
    } _flags;
}
- (id)prepareWithInvocationTarget:(id)target;
- (void)undo;
- (void)redo;
- (BOOL)isUndoing;
- (BOOL)isRedoing;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (int)undoCount;
- (int)redoCount;
- (void)setActionName:(NSString *)string;
- (NSString *)undoMenuItemTitle;
- (NSString *)redoMenuItemTitle;
- (NSString *)undoMenuTitleForUndoActionName:(NSString *)name;
- (NSString *)redoMenuTitleForUndoActionName:(NSString *)name;

- (void)removeAllActions;
- (void)removeAllActionsWithTarget:(id)target;

- (DBUndoObject *)undoObjectAtIndex:(int)index;
- (DBUndoObject *)redoObjectAtIndex:(int)index;
@end
 
@interface NSDocument (SpecialUndoManager)
- (DBUndoManager *)specialUndoManager;
@end                                  
