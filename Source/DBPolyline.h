//
//  DBPolyline.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBShape.h"

typedef struct _DBPolylinePoint {
	NSPoint	point;
	
	BOOL closePath;
	BOOL subPathStart;
} DBPolylinePoint;

@interface DBPolyline : DBShape <NSCoding>{
	DBPolylinePoint *_points;
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

- (DBPolylinePoint *)points;
- (int)pointCount;
- (void)setPoints:(NSPoint *)points count:(int)count;

- (void)setPoint:(NSPoint)p atIndex:(int)i;
- (void)setLineIsClosed:(BOOL)flag;

- (NSPoint)nearestPointOfPathToPoint:(NSPoint)point segment:(int *)seg;
                                      
- (void)insertPoints:(NSPoint *)point atIndexes:(NSIndexSet *)indexes;
- (void)removePointsAtIndexes:(NSIndexSet *)indexes;
- (void)replacePoints:(DBPolylinePoint *)points count:(int)count insertion:(BOOL)insert;

- (void)deletePathBetween:(int)index1 and:(int)index2;
- (NSBezierPath *)pathFragmentBetween:(int)index1 and:(int)index2;
@end

static int DBSubPolyPathBegging(DBPolylinePoint *points, int pCount)
{
	int i;
	
	for (i = pCount-1; i > 0; i--) {
		if(points[i].subPathStart){
			return i;
		}
	}
	
	return 0;
}
