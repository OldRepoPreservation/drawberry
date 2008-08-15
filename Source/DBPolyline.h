//
//  DBPolyline.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBShape.h"


@interface DBPolyline : DBShape <NSCoding>{
	NSPoint *_points;
	int _pointCount;
	
	BOOL _lineIsClosed;
	
	NSBezierPath *_path;
	NSBezierPath *_oldPathFrag;
	
	NSMutableIndexSet *_selectedPoints;
}
- (void)updatePath;
- (void)putPathInRect:(NSRect)newRect;

- (void)deselectAllPoints;
- (void)selectPointAtIndex:(int)index;
- (void)deselectPointAtIndex:(int)index;
- (void)togglePointSelectionAtIndex:(int)index;
- (BOOL)pointAtIndexIsSelected:(int)index; 

- (NSPoint *)points;
- (int)pointCount;
- (void)setPoints:(NSPoint *)points count:(int)count;

- (void)setPoint:(NSPoint)p atIndex:(int)i;
- (void)setLineIsClosed:(BOOL)flag;

- (NSPoint)nearestPointOfPathToPoint:(NSPoint)point segment:(int *)seg;
                                      
- (void)insertPoints:(NSPoint *)point atIndexes:(NSIndexSet *)indexes;
- (void)removePointsAtIndexes:(NSIndexSet *)indexes;


- (void)deletePathBetween:(int)index1 and:(int)index2;
- (NSBezierPath *)pathFragmentBetween:(int)index1 and:(int)index2;
@end
