//
//  DBPolyline.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//


/*
 *	This class is kept for backward compatibility
 *	Its main purpose is to convert an encoded DBPolyline object into a DBBezierPath object
 *
 */





#import "DBShape.h"

typedef struct _DBPolylinePoint {
	NSPoint	point;
	
	BOOL closePath;
	BOOL subPathStart;
} DBPolylinePoint;

@class DBBezierCurve;

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
                                      
- (void)insertPoint:(NSPoint)points atIndex:(int)index;
- (void)replacePoints:(DBPolylinePoint *)points count:(int)count type:(int)replacingType;

- (void)deletePathBetween:(int)index1 and:(int)index2;
- (NSBezierPath *)pathFragmentBetween:(int)index1 and:(int)index2;


- (DBBezierCurve *)convertToCurve;
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
