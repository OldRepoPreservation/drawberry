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

+ (void)initialize
{
    [self exposeBinding:@"groups"];
}

- (id)init
{
    self = [super init];
    if (self) {
        _groups = [[NSMutableArray alloc] init];
        _newGroupIndex = 1;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (DBDocument *)document
{
    return _document;
}

- (void)setDocument:(DBDocument *)doc
{
    _document = doc;
}

- (DBUndoManager *)documentUndoManager
{
	return [_document specialUndoManager];
}

- (NSArray *)groups
{
    return [[_groups copy] autorelease]; // return an immutable copy
}
- (int)countOfGroups
{
    return [_groups count];
}
- (void)addGroup:(DBGroup *)aGroup
{
    [self insertGroups:[NSArray arrayWithObject:aGroup] atIndexes:[NSIndexSet indexSetWithIndex:[_groups count]]];
}

- (void)insertGroups:(NSArray *)groupsArray atIndexes:(NSIndexSet *)indexes
{
    [self willChangeValueForKey:@"groups"];
    [_groups insertObjects:groupsArray atIndexes:indexes];
	[groupsArray makeObjectsPerformSelector:@selector(setGroupController:) withObject:self];
    

    DBUndoManager *undoMngr = [_document specialUndoManager]; 
	[[undoMngr prepareWithInvocationTarget:self] removeGroupAtIndexes:indexes];
    if(![undoMngr isUndoing]){
        [undoMngr setActionName:NSLocalizedString(@"Add Group", nil)];
    }else{
        [undoMngr setActionName:NSLocalizedString(@"Remove Group", nil)];	
    }
    for (DBGroup *group in groupsArray) {
        [group setShapesGroup];
    }

    [self didChangeValueForKey:@"groups"];
    [[_document drawingView] setNeedsDisplay:YES];

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
    [self willChangeValueForKey:@"groups"];
    [self removeGroupAtIndexes:[NSIndexSet indexSetWithIndex:[self indexOfGroup:aGroup]]];
    [self didChangeValueForKey:@"groups"];
}

- (void)removeGroupAtIndexes:(NSIndexSet *)indexes
{
    [self willChangeValueForKey:@"groups"];
    DBUndoManager *undoMngr = [_document specialUndoManager]; 
	[[undoMngr prepareWithInvocationTarget:self] insertGroups:[_groups objectsAtIndexes:indexes] atIndexes:indexes];
	if(![undoMngr isUndoing]){
		[undoMngr setActionName:NSLocalizedString(@"Remove Group", nil)];
	}else{
		[undoMngr setActionName:NSLocalizedString(@"Add Group", nil)];	
	}
	

    for (DBGroup *group in [_groups objectsAtIndexes:indexes]) {
        [group unsetShapesGroup];
    }
    [_groups removeObjectsAtIndexes:indexes];

    [self didChangeValueForKey:@"groups"];
    [[_document drawingView] setNeedsDisplay:YES];
}
- (void)setGroups:(NSArray *)newGroups
{
    [self willChangeValueForKey:@"groups"];
    [_groups setArray:newGroups];
	[_groups makeObjectsPerformSelector:@selector(setGroupController:) withObject:self];
    [self didChangeValueForKey:@"groups"];

}


- (void)addGroupWithShapes:(NSArray *)shapes
{
    DBGroup *group = [[DBGroup alloc] initWithName:[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"Group", nil),_newGroupIndex++]];
    
    [group addShapes:shapes];
    
    [self willChangeValueForKey:@"groups"];
    [self addGroup:group];
    [self didChangeValueForKey:@"groups"];

    [group release];
}

- (void)unionGroups:(NSSet *)groups andAddShapes:(NSArray *)shapes
{
    [self willChangeValueForKey:@"groups"];
    DBGroup *topGroup = nil;
    NSMutableSet *otherGroups = [groups mutableCopy];
    
    for (DBGroup *g in _groups) {
        if([groups containsObject:g]){
            if (!topGroup) {
                topGroup = g;
                break;
            }
        }
    }
    if(topGroup){
        [otherGroups removeObject:topGroup];
        
        [self unionGroups:otherGroups andShapes:shapes toGroup:topGroup];
    }
    [otherGroups release];
    [self didChangeValueForKey:@"groups"];
}

- (void)unionGroups:(NSSet *)groups andShapes:(NSArray *)shapes toGroup:(DBGroup *)uGroup
{
    [self willChangeValueForKey:@"groups"];
    DBUndoManager *undoMngr = [_document specialUndoManager]; 
	[[undoMngr prepareWithInvocationTarget:self] diffGroups:groups andShapes:shapes ofGroup:uGroup];
    [undoMngr setActionName:NSLocalizedString(@"Union Group", nil)]; // no reciprocate action 
    
    for (DBGroup *g in groups) {
        if ([_groups containsObject:g]) {
            [uGroup addShapes:[g shapes]];
        }
    }
    
    [_groups removeObjectsInArray:[groups allObjects]];
    [uGroup addShapes:shapes];
    [self didChangeValueForKey:@"groups"];
}

- (void)diffGroups:(NSSet *)groups andShapes:(NSArray *)shapes ofGroup:(DBGroup *)uGroup
{
    [self willChangeValueForKey:@"groups"];
    DBUndoManager *undoMngr = [_document specialUndoManager]; 
	[[undoMngr prepareWithInvocationTarget:self] unionGroups:groups andShapes:shapes toGroup:uGroup];
    [undoMngr setActionName:NSLocalizedString(@"Union Groups", nil)]; // no reciprocate action  	
	
    
    for (DBGroup *g in groups) {
        [uGroup removeShapes:[g shapes]];
        [g setShapesGroup];
    }
    
    [uGroup removeShapes:shapes];
    [_groups addObjectsFromArray:[groups allObjects]];
    
    [self didChangeValueForKey:@"groups"];
}

- (void)ungroup:(NSArray *)groups
{
    NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
    
    for (DBGroup *g in groups) {
        if([_groups containsObject:g]){
            [is addIndex:[_groups indexOfObject:g]];
        }
    }
    
    [self removeGroupAtIndexes:is];
}


- (void)addShapes:(NSArray *)shapes toGroup:(DBGroup *)group
{
    if(![_groups containsObject:group]){
        [self addGroup:group];
    }
    [group addShapes:shapes];
}

- (void)removeShapes:(NSArray *)shapes toGroup:(DBGroup *)group
{
    if([_groups containsObject:group]){
        
        for (DBShape *shape in shapes) {
            [group removeShape:shape];
        }
        
        if([group countOfShapes] == 0){
            [_groups removeObject:group];
        }
    }
}

- (void) removeShapeOfGroups:(NSArray *)groups toGroup:(DBGroup *)group
{
    for (DBGroup *g in groups) {
        [self removeShapeOfGroups:[g shapes] toGroup:group];
    }
}

@end
