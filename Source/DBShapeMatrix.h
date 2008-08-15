//
//  DBShapeMatrix.h
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBMatrix.h"

extern NSString *DBSelectedCellDidChange;

@interface DBShapeMatrix : DBMatrix {
	id _currentShapeCell;
	
	NSCell *_draggedCell;
}                         
- (id)currentShapeCell;
- (void)setCurrentShapeCell:(NSCell *)cell;
@end
