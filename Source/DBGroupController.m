//
//  DBGroupController.m
//  DrawBerry
//
//  Created by Raphael Bost on 29/04/12.
//  Copyright 2012 Ecole Polytechnique. All rights reserved.
//

#import "DBGroupController.h"

#import "DBGroup.h"

@implementation DBGroupController

- (id)init
{
    self = [super init];
    if (self) {
        _groups = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (DBUndoManager *)documentUndoManager
{
	return [_document specialUndoManager];
}

- (NSArray *)groups
{
    return _groups;
}
- (int)countOfGroups
{
    return [_groups count];
}
- (void)addGroup:(DBGroup *)aGroup
{
    [_groups addObject:aGroup];
    [aGroup setGroupController:self];
}

- (void)insertGroups:(NSArray *)groupsArray atIndexes:(NSIndexSet *)indexes
{
    [_groups insertObjects:groupsArray atIndexes:indexes];
	[groupsArray makeObjectsPerformSelector:@selector(setGroupController:) withObject:self];

}
- (DBGroup *)groupAtIndex:(unsigned int)i
{
    return [_groups objectAtIndex:i];
}
- (unsigned int)indexOfGroup:(DBGroup *)aGroup
{
    return [_groups indexOfObject:aGroup];
}
- (void)removeGroup:(DBGroup *)aGroup
{
    [_groups removeObject:aGroup];
}

- (void)removeGroupAtIndexes:(NSIndexSet *)indexes
{
    [_groups removeObjectsAtIndexes:indexes];
}
- (void)setGroups:(NSArray *)newGroups
{
    [_groups setArray:newGroups];
	[_groups makeObjectsPerformSelector:@selector(setGroupController:) withObject:self];

}


- (void)addGroupWithShapes:(NSArray *)shapes
{
    DBGroup *group = [[DBGroup alloc] init];
    
    [group addShapes:shapes];
    
    [self addGroup:group];
    [group release];
}

- (void)ungroup:(DBGroup *)group
{
    if([_groups containsObject:group]){
        NSArray *shapes = [group shapes];
        for (DBShape *shape in shapes) {
            [shape setGroup:nil];
        }
        
        [_groups removeObject:group];
    }
}
@end
