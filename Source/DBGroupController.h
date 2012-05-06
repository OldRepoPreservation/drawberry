//
//  DBGroupController.h
//  DrawBerry
//
//  Created by Raphael Bost on 29/04/12.
//  Copyright 2012 Ecole Polytechnique. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBDocument.h"
@class DBGroup;

@interface DBGroupController : NSObject {
@private
    NSMutableArray *_groups;
    
    DBDocument *_document;
}

- (DBDocument *)document;
- (void)setDocument:(DBDocument *)doc;
- (DBUndoManager *)documentUndoManager;


- (NSArray *)groups;
- (int)countOfGroups;
- (void)addGroup:(DBGroup *)aGroup;
- (void)insertGroups:(NSArray *)groupsArray atIndexes:(NSIndexSet *)indexes;
- (DBGroup *)groupAtIndex:(unsigned int)i;
- (unsigned int)indexOfGroup:(DBGroup *)aGroup;
- (void)removeGroup:(DBGroup *)aGroup;
- (void)removeGroupAtIndexes:(NSIndexSet *)indexes;
- (void)setGroups:(NSArray *)newGroups;

- (void)addGroupWithShapes:(NSArray *)shapes;
- (void)ungroup:(NSArray *)groups;
@end
