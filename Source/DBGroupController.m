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
    return [_groups copy]; // return an immutable copy
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
    [self removeGroupAtIndexes:[NSIndexSet indexSetWithIndex:[self indexOfGroup:aGroup]]];
}

- (void)removeGroupAtIndexes:(NSIndexSet *)indexes
{
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
    [[_document drawingView] setNeedsDisplay:YES];
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

- (void)unionGroups:(NSSet *)groups andAddShapes:(NSArray *)shapes
{
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
    if(!topGroup)
        return;
    
    [otherGroups removeObject:topGroup];

    [self unionGroups:otherGroups andShapes:shapes toGroup:topGroup];
    
    [otherGroups release];
}

- (void)unionGroups:(NSSet *)groups andShapes:(NSArray *)shapes toGroup:(DBGroup *)uGroup
{
    DBUndoManager *undoMngr = [_document specialUndoManager]; 
	[[undoMngr prepareWithInvocationTarget:self] diffGroups:groups andShapes:shapes ofGroup:uGroup];
    [undoMngr setActionName:NSLocalizedString(@"Union Group", nil)]; // no reciprocate action 

    for (DBGroup *g in groups) {
        if ([_groups containsObject:g]) {
            [uGroup addShapes:[g shapes]];
        }
    }
    
    [uGroup addShapes:shapes];
}

- (void)diffGroups:(NSSet *)groups andShapes:(NSArray *)shapes ofGroup:(DBGroup *)uGroup
{
    DBUndoManager *undoMngr = [_document specialUndoManager]; 
	[[undoMngr prepareWithInvocationTarget:self] unionGroups:groups andShapes:shapes toGroup:uGroup];
    [undoMngr setActionName:NSLocalizedString(@"Union Groups", nil)]; // no reciprocate action  	
	
    
    for (DBGroup *g in groups) {
        if ([_groups containsObject:g]) {
            [uGroup removeShapes:[g shapes]];
            [g setShapesGroup];
        }
    }
    
    [uGroup removeShapes:shapes];

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
