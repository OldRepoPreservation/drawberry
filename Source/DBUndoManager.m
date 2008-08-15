//
//  DBUndoManager.m
//  DrawBerry
//
//  Created by Raphael Bost on 23/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBUndoManager.h"
#import "DBUndoObject.h"
#import "DBUndoStack.h"            

NSString *DBUndoManagerWillUndoChangeNotification = @"UndoManager Will Undo Change";
NSString *DBUndoManagerWillRedoChangeNotification = @"UndoManager Will Redo Change";
NSString *DBUndoManagerDidUndoChangeNotification = @"UndoManager Did Undo Change";
NSString *DBUndoManagerDidRedoChangeNotification = @"UndoManager Did Redo Change";   
NSString *DBUndoManagerUndoActionsDidChange = @"UndoManager Actions Did Change";
NSString *DBUndoManagerUndoActionsWillChange = @"UndoManager Actions Will Change";

@implementation DBUndoManager
- (id)init
{
	self = [super init]; 
	
	_undoStack = [[DBUndoStack alloc] init];
	_redoStack = [[DBUndoStack alloc] init];
	
	return self;
} 

- (void)dealloc
{
	[_undoStack release];
	[_redoStack release];
	
	[super dealloc];
}

- (id)prepareWithInvocationTarget:(id)target
{
	_preparedInvocationTarget = target;
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	NSMethodSignature *result = nil;
	
	if(_preparedInvocationTarget){
		result = [_preparedInvocationTarget methodSignatureForSelector:aSelector];
	}
	if(!result){
		result = [super methodSignatureForSelector:aSelector];
	}
	return result;
}   

- (void)forwardInvocation:(NSInvocation *)invocation
{
	if(!_preparedInvocationTarget){
		// raise exception
		[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invocation Target not prepared" userInfo:nil] raise]; 
	}
	SEL selector = [invocation selector];
	if([_preparedInvocationTarget respondsToSelector:selector]){
		DBUndoObject *undoObject;
		DBUndoStack *stack = _undoStack;
		
		if(_flags.undoing){
			stack = _redoStack;
		}else if(_flags.redoing){
			stack = _undoStack;
		}else{
			[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerUndoActionsWillChange object:self];
			
		}
		
		undoObject = [[DBUndoObject alloc] initWithTarget:_preparedInvocationTarget invocation:invocation actionName:nil];
		[stack push:undoObject];
		[undoObject release];
		
		// clear the redo stack if we are not undoing neither redoing
		if (!_flags.undoing && !_flags.redoing) {
			[_redoStack removeAllObjects];
			[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerUndoActionsDidChange object:self];
		}
		_preparedInvocationTarget = nil;		
	}else{
		[self doesNotRecognizeSelector:selector];
	}
}

- (void)undo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerWillUndoChangeNotification object:self];
	_flags.undoing = 1;
	
	[_undoStack popAndInvoke];

	_flags.undoing = 0;
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerDidUndoChangeNotification object:self];
}   

- (BOOL)isUndoing
{
	return _flags.undoing;
}                         

- (void)redo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerWillRedoChangeNotification object:self];
	_flags.redoing = 1;
	
	[_redoStack popAndInvoke];
	
	_flags.redoing = 0;
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerDidRedoChangeNotification object:self];
}

- (BOOL)isRedoing
{
	return _flags.redoing;
}                         

- (void)setActionName:(NSString *)string
{
	if(_flags.redoing){
		[[_undoStack topUndoObject] setActionName:string];
	}else if(_flags.undoing){
		[[_redoStack topUndoObject] setActionName:string];
	}else{
		[[_undoStack topUndoObject] setActionName:string];
	}
}

- (NSString *)undoActionName
{
	return [[_undoStack topUndoObject] actionName];
}
- (NSString *)redoActionName
{
	return [[_redoStack topUndoObject] actionName];
}

- (NSString *)undoMenuItemTitle
{
	return [self undoMenuTitleForUndoActionName:[self undoActionName]];
}
- (NSString *)redoMenuItemTitle
{
	return [self redoMenuTitleForUndoActionName:[self redoActionName]];
}

- (NSString *)undoMenuTitleForUndoActionName:(NSString *)name
{
	if(!name)
		name = @"";
		
	return [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"Undo",@"UndoLoc",nil), name];
}
- (NSString *)redoMenuTitleForUndoActionName:(NSString *)name
{
	if(!name)          
		name = @"";
                    
	
	return [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"Redo",@"UndoLoc",nil), name];
}

- (BOOL)canUndo
{
	return ([_undoStack count] > 0 ? YES : NO);
}
- (int)undoCount
{
	return [_undoStack count];
}

- (BOOL)canRedo
{
	return ([_redoStack count] > 0 ? YES : NO);
}
- (int)redoCount
{
	return [_redoStack count];
}

- (void)removeAllActions
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerUndoActionsWillChange object:self];
	[_undoStack removeAllObjects];
	[_redoStack removeAllObjects];
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerUndoActionsDidChange object:self];
}

- (void)removeAllActionsWithTarget:(id)target
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerUndoActionsWillChange object:self];
	[_undoStack removeAllObjectsWithTarget:target];
	[_redoStack removeAllObjectsWithTarget:target];
	[[NSNotificationCenter defaultCenter] postNotificationName:DBUndoManagerUndoActionsDidChange object:self];
}

- (DBUndoObject *)undoObjectAtIndex:(int)index
{
	return [_undoStack objectInStackAtIndex:index];
}   

- (DBUndoObject *)redoObjectAtIndex:(int)index
{
	return [_redoStack objectInStackAtIndex:index];
}
@end
