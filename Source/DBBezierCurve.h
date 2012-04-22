//
//  DBBezierCurve.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/05/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBShape.h"

typedef struct _DBCurvePoints {
	NSPoint	point;
	
	BOOL hasControlPoint1;
	NSPoint controlPoint1;
	BOOL hasControlPoint2;
	NSPoint controlPoint2;

	BOOL hasControlPoints;
	
	BOOL closePath;
	BOOL subPathStart;
} DBCurvePoint;

@interface DBBezierCurve : DBShape <NSCoding>{
 	DBCurvePoint *_points;
	int _pointCount;
	
	BOOL _lineIsClosed;
    
    BOOL _isPolyline;
	
	NSBezierPath *_path;
	NSBezierPath *_controlPointsPath;
	NSBezierPath *_tempPath;
	NSBezierPath *_oldPathFrag;

	NSMutableIndexSet *_selectedPoints;
}
- (id)initWithBezierPath:(NSBezierPath *)path;
- (id)initWithPolylinePoints:(NSPoint *)points count:(int)pCount closed:(BOOL)closed;

- (void)updatePath;
- (void)putPathInRect:(NSRect)newRect;

- (void)deselectAllPoints;
- (void)selectPointAtIndex:(int)index;
- (void)deselectPointAtIndex:(int)index;
- (void)togglePointSelectionAtIndex:(int)index;
- (BOOL)pointAtIndexIsSelected:(int)index; 

- (DBCurvePoint)nearestPointOfPathToPoint:(NSPoint)point bezSegment:(int *)seg beforePoint:(DBCurvePoint *)beforePt afterPoint:(DBCurvePoint *)afterPt;
- (NSPoint)nearestPointOfPath:(NSPoint)point;

- (void)setPoint:(DBCurvePoint)p atIndex:(int)i;

- (BOOL)isPolyline;
- (void)setPolyline:(BOOL)flag;

- (void)insertPoint:(DBCurvePoint)point atIndex:(int)index previousPoint:(DBCurvePoint)previous nextPoint:(DBCurvePoint)next;
- (void)removePointAtIndex:(int)index previousPoint:(DBCurvePoint)previous nextPoint:(DBCurvePoint)next;
- (void)replacePoints:(DBCurvePoint *)points count:(int)count type:(int)replacingType;

- (void)hardenPointsAtIndexesFirstControlPoint:(NSIndexSet *)is1 secondControlPoint:(NSIndexSet *)is2;
- (void)softenPointsAtIndexesFirstControlPoint:(NSIndexSet *)is1 secondControlPoint:(NSIndexSet *)is2;

- (void)deletePathBetween:(int)index1 and:(int)index2;
- (NSBezierPath *)pathFragmentBetween:(int)index1 and:(int)index2;

@end


static DBCurvePoint DBMakeCurvePoint(NSPoint p){
	DBCurvePoint cp;
	cp.point = p;
	cp.controlPoint1 = p;
	cp.controlPoint2 = p;
	cp.closePath = NO;
	cp.subPathStart = NO;
	cp.hasControlPoints = NO;
	cp.hasControlPoint1 = NO;
	cp.hasControlPoint2 = NO;
	
	;return cp;
}

static DBCurvePoint DBMakeAnotherCurvePoint(NSPoint p){
	DBCurvePoint cp;
	cp.point = p;
	cp.controlPoint1 = NSMakePoint(p.x+10, p.y+15); cp.hasControlPoint1 = YES;
	cp.controlPoint2 = NSMakePoint(p.x-10, p.y-15); cp.hasControlPoint2 = YES;
	cp.closePath = NO;
	cp.subPathStart = NO;

	return cp;
}


static int DBSubPathBegging(DBCurvePoint *points, int pCount)
{
	int i;
	
	for (i = pCount-1; i > 0; i--) {
		if(points[i].subPathStart){
			return i;
		}
	}
	
	return 0;
}


/*
static DBCurvePoint DBMakeCurvePoint(NSPoint p, NSPoint cp1, NSPoint cp2){
	DBCurvePoint cp;
	cp.point = p;
	cp.controlPoint1 = cp1;
	cp.controlPoint2 = cp2;
	
	return cp;
}
*/