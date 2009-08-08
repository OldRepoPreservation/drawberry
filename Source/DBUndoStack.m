//
//  DBUndoStack.m
//  DrawBerry
//
//  Created by Raphael Bost on 23/07/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBUndoStack.h"
#import "DBUndoObject.h"


@implementation DBUndoStack
- (id)init
{
	self = [super init];
	
	_stackObjects = [[NSMutableArray alloc] init];            
	
	return self;
}

- (void)dealloc
{
	[_stackObjects release];
	
	[super dealloc];
}

- (void)push:(DBUndoObject *)object
{
	[_stackObjects addObject:object];
}

- (BOOL)popAndInvoke
{
	if([_stackObjects count] > 0){
		[(DBUndoObject *)[_stackObjects lastObject] invoke];
		[_stackObjects removeLastObject]; 
		return YES;
	}
	return NO;
}

- (unsigned)count
{
	return [_stackObjects count];
}  

- (void)removeAllObjects
{
	[_stackObjects removeAllObjects];
}

- (void)removeAllObjectsWithTarget:(id)target
{
	NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [_stackObjects objectEnumerator];
	DBUndoObject * object;

	while((object = [e nextObject])){
		if([object target] == target){
			[objectsToRemove addObject:object];
		}
	}
	
	[_stackObjects removeObjectsInArray:objectsToRemove];
	[objectsToRemove release];
}

- (void)removeObject:(DBUndoObject *)object
{
	[_stackObjects removeObject:object];
}

- (DBUndoObject *)topUndoObject
{
	return [_stackObjects lastObject];
}

- (DBUndoObject *)objectInStackAtIndex:(int)index
{
	return [_stackObjects objectAtIndex:index];
}
@end
