//
//  DBLayerArrayController.m
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBReverseArrayController.h"


@implementation DBReverseArrayController
- (id)initWithContent:(id)content
{
	self = [super initWithContent:content];
	            
	_isReversed = YES;
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aCoder
{
	self = [super initWithCoder:aCoder];
	
	_isReversed = YES;
	
	return self;
}

- (BOOL)isReversed
{
	return _isReversed;
}

- (void)setReversed:(BOOL)newIsReversed
{
	_isReversed = newIsReversed;
	[self rearrangeObjects];
}

- (NSArray *)arrangeObjects:(NSArray *)objects
{
	if(_isReversed)
	{   
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
		
		NSEnumerator *e = [objects reverseObjectEnumerator];
		id object;

		while((object = [e nextObject])){
			[array addObject:object];
		}
		
		return [super arrangeObjects:array]; 
	}
	
	return [super arrangeObjects:objects];
	
}

- (void)add:(id)sender
{
	id newObject;
	
	newObject = [self newObject];
	
	[self insertObject:newObject atArrangedObjectIndex:0];
	
	[newObject release];
	
	if([self selectsInsertedObjects])
		[self setSelectionIndex:0];
}

- (BOOL)canRemove
{
	return ([super canRemove] && ([[self content] count] > 1));
}

@end
