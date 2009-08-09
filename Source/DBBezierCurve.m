//
//  DBBezierCurve.m
//  DrawBerry
//
//  Created by Raphael Bost on 16/05/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBBezierCurve.h"

#define DB_BEZIER_ERROR 0.1
#define DB_BEZIER_SEG_LENGTH 1.0

@class NSBitmapGraphicsContext;

static double distanceBetween(NSPoint a, NSPoint b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  return sqrt (dx * dx + dy * dy);
}
 

static void subdivideBezier(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4])
{
  NSPoint q;
  
  // Subdivide the Bézier further
  bez1[0].x = bez[0].x;
  bez1[0].y = bez[0].y;
  bez2[3].x = bez[3].x;
  bez2[3].y = bez[3].y;
  
  q.x = (bez[1].x + bez[2].x) / 2.0;
  q.y = (bez[1].y + bez[2].y) / 2.0;
  bez1[1].x = (bez[0].x + bez[1].x) / 2.0;
  bez1[1].y = (bez[0].y + bez[1].y) / 2.0;
  bez2[2].x = (bez[2].x + bez[3].x) / 2.0;
  bez2[2].y = (bez[2].y + bez[3].y) / 2.0;
  
  bez1[2].x = (bez1[1].x + q.x) / 2.0;
  bez1[2].y = (bez1[1].y + q.y) / 2.0;
  bez2[1].x = (q.x + bez2[2].x) / 2.0;
  bez2[1].y = (q.y + bez2[2].y) / 2.0;
  
  bez1[3].x = bez2[0].x = (bez1[2].x + bez2[1].x) / 2.0;
  bez1[3].y = bez2[0].y = (bez1[2].y + bez2[1].y) / 2.0;
}

// Subdivide a Bézier (specific division)
static void subdivideBezierAtT(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4], float t)
{
  NSPoint q;
  float mt = 1 - t;
  
  // Subdivide the Bézier further
  bez1[0].x = bez[0].x;
  bez1[0].y = bez[0].y;
  bez2[3].x = bez[3].x;
  bez2[3].y = bez[3].y;
  
  q.x = mt * bez[1].x + t * bez[2].x;
  q.y = mt * bez[1].y + t * bez[2].y;
  bez1[1].x = mt * bez[0].x + t * bez[1].x;
  bez1[1].y = mt * bez[0].y + t * bez[1].y;
  bez2[2].x = mt * bez[2].x + t * bez[3].x;
  bez2[2].y = mt * bez[2].y + t * bez[3].y;
  
  bez1[2].x = mt * bez1[1].x + t * q.x;
  bez1[2].y = mt * bez1[1].y + t * q.y;
  bez2[1].x = mt * q.x + t * bez2[2].x;
  bez2[1].y = mt * q.y + t * bez2[2].y;
  
  bez1[3].x = bez2[0].x = mt * bez1[2].x + t * bez2[1].x;
  bez1[3].y = bez2[0].y = mt * bez1[2].y + t * bez2[1].y;
}

// Length of a Bézier curve
static double lengthOfBezier(const  NSPoint bez[4], double acceptableError)
{
  double   polyLen = 0.0;
  double   chordLen = distanceBetween (bez[0], bez[3]);
  double   retLen, errLen;
  unsigned n;
  
  for (n = 0; n < 3; ++n)
    polyLen += distanceBetween (bez[n], bez[n + 1]);
  
  errLen = polyLen - chordLen;
  
  if (errLen > acceptableError) {
    NSPoint left[4], right[4];
    subdivideBezier (bez, left, right);
    retLen = (lengthOfBezier (left, acceptableError) 
	      + lengthOfBezier (right, acceptableError));
  } else {
    retLen = 0.5 * (polyLen + chordLen);
  }
  
  return retLen;
}

// Split a Bézier curve at a specific length
static double subdivideBezierAtLength (const NSPoint bez[4],
				       NSPoint bez1[4],
				       NSPoint bez2[4],
				       double length,
				       double acceptableError)
{
  float top = 1.0, bottom = 0.0;
  float t, prevT;
  
  prevT = t = 0.5;
  for (;;) {
    double len1;
    
    subdivideBezierAtT (bez, bez1, bez2, t);
    
    len1 = lengthOfBezier (bez1, 0.5 * acceptableError);
    
    if (fabs (length - len1) < acceptableError)
      return len1;
    
    if (length > len1) {
      bottom = t;
      t = 0.5 * (t + top);
    } else if (length < len1) {
      top = t;
      t = 0.5 * (bottom + t);
    }
    
    if (t == prevT)
      return len1;
    
    prevT = t;
  }
}

DBCurvePoint * insertCurvePointAtIndex(DBCurvePoint newPoint, int index, DBCurvePoint *points, int pointsCount)
{
	DBCurvePoint *newPoints;
	newPoints = malloc(sizeof(DBCurvePoint)*(pointsCount+1));
                
	int i;

	for( i = 0; i < index; i++ )
	{                            
		newPoints[i] = points[i];
	}                       
	
	newPoints[index] = newPoint;

	for(i = index+1; i < pointsCount+1; i++)
	{
		newPoints[i] = points[i-1];
	}

	free(points);
	return newPoints;
}


NSPoint nearestPointInArray(NSPoint array[], int count, NSPoint point)
{
	NSPoint nearest;
	float nearestDist,dist, dX, dY;
	
	nearest = array[0];
	dX = point.x - nearest.x; dY = point.y - nearest.y;
	nearestDist = dX*dX + dY*dY;
	
	int i;

	for( i = 1; i < count; i++ )
	{   
		dX = point.x - array[i].x; dY = point.y - array[i].y;
		dist = dX*dX + dY*dY;
		
		if(nearestDist > dist){
			nearest = array[i];
			nearestDist = dist;
		}
	}
	
	return nearest;
}

DBCurvePoint * removeCurvePointAtIndex( int index, DBCurvePoint *points, int pointsCount)
{
	DBCurvePoint *newPoints;
	newPoints = malloc(sizeof(DBCurvePoint)*(pointsCount-1));
	
	int i;
	
	for( i = 0; i < index; i++ )
	{                            
		newPoints[i] = points[i];
	}                       
	
	
	for(i = index+1; i < pointsCount; i++)
	{
		newPoints[i-1] = points[i];
	}
	
	free(points);
	return newPoints;
}

@implementation DBBezierCurve

- (id)init
{
	self = [super init];
	            
	_selectedPoints = [[NSMutableIndexSet alloc] init];
	
	return self;
}

- (id)initWithBezierPath:(NSBezierPath *)path
{
	self = [self init];
	
	_pointCount = 1;
	
	int elementCount;
	NSPoint associatedPoints [3];
	NSBezierPathElement elementType;
	
	elementCount = [path elementCount];
		
	_points = malloc(sizeof(DBCurvePoint));
	
	_points[0].point = NSZeroPoint;
	_points[0].controlPoint1 = NSZeroPoint;
	_points[0].controlPoint2 = NSZeroPoint;            

    elementType = [path elementAtIndex:0 associatedPoints:associatedPoints];
	
	if(elementType == NSMoveToBezierPathElement){
		_points[0].point = associatedPoints[0];
		_points[0].controlPoint1 = associatedPoints[0];
		_points[0].controlPoint2 = associatedPoints[0];   
        _points[0].closePath = NO;
        _points[0].subPathStart = YES;
		
//		_points[0].hasControlPoint2 = YES;

	}                                                              
	
	int i;
	int beginningPoint;
	
	beginningPoint = 0;
	
	for( i = 1; i < elementCount; i++ )
	{
	    elementType = [path elementAtIndex:i associatedPoints:associatedPoints];
	
		if(elementType == NSClosePathBezierPathElement){
//			NSLog(@"close path");
			if(NSEqualPoints(_points[beginningPoint].point, _points[_pointCount-1].point)){
//				NSLog(@"points egaux");
				_points[beginningPoint].controlPoint2 = _points[_pointCount-1].controlPoint2;
				_points[beginningPoint].hasControlPoint2 = YES;

				_points = removeCurvePointAtIndex(_pointCount-1,_points,_pointCount);
				_pointCount--;	
			}
			
			_points[_pointCount-1].closePath = YES;
		}else if(elementType == NSMoveToBezierPathElement){

			beginningPoint = _pointCount;
			_pointCount++;
			_points = realloc(_points, _pointCount*sizeof(DBCurvePoint));
			
			_points[_pointCount-1].point = associatedPoints[0];
			_points[_pointCount-1].controlPoint1 = associatedPoints[0];
			_points[_pointCount-1].controlPoint2 = associatedPoints[0];   
			_points[_pointCount-1].closePath = NO;
			_points[_pointCount-1].subPathStart = YES;
			
			_points[_pointCount-1].hasControlPoint2 = NO;
			
		}else if(elementType == NSLineToBezierPathElement){
			_pointCount++;
			_points = realloc(_points, _pointCount*sizeof(DBCurvePoint));
			_points[_pointCount-2].controlPoint1 = _points[_pointCount-2].point;
			_points[_pointCount-1].point = associatedPoints[0];
			_points[_pointCount-1].controlPoint2 = associatedPoints[0];
			_points[_pointCount-1].controlPoint1 = associatedPoints[0];
			_points[_pointCount-1].hasControlPoints = NO;		
			_points[_pointCount-1].closePath = NO;		
			_points[_pointCount-1].subPathStart = NO;	
			
			_points[_pointCount-2].hasControlPoint1 = NO;
			_points[_pointCount-1].hasControlPoint2 = NO;

		}else{
			_pointCount++;
			_points = realloc(_points, _pointCount*sizeof(DBCurvePoint));
			_points[_pointCount-2].controlPoint1 = associatedPoints[0];
			_points[_pointCount-1].controlPoint2 = associatedPoints[1];            			
			_points[_pointCount-1].point = associatedPoints[2];
			_points[_pointCount-1].hasControlPoints = YES;		
			_points[_pointCount-1].closePath = NO;		
			_points[_pointCount-1].subPathStart = NO;	
			
			_points[_pointCount-2].hasControlPoint1 = YES;
			_points[_pointCount-1].hasControlPoint2 = YES;

		}
	}
			
	if(NSEqualPoints(_points[beginningPoint].point, _points[_pointCount-1].point)){
		_points[beginningPoint].controlPoint2 = _points[_pointCount-1].controlPoint2;
		_points[beginningPoint].hasControlPoint2 = YES;
		_points = removeCurvePointAtIndex(_pointCount-1,_points,_pointCount);
		_pointCount--;
		_points[_pointCount-1].closePath = YES;
	}
	
	return self;
}

- (id)initWithPolylinePoints:(NSPoint *)points count:(int)pCount closed:(BOOL)closed
{
	self = [self init];
	
	_points = malloc(pCount*sizeof(DBCurvePoint));
	
	int i;
	
	i = 0;
	
	for (i = 0; i < pCount; i++) {
		_points[i] = DBMakeCurvePoint(points[i]);
	}
	
	_points[0].subPathStart = YES;
	_points[pCount-1].closePath = closed;
	
	_pointCount = pCount;
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	            	
	_pointCount = [decoder decodeIntForKey:@"Point count"];
	_lineIsClosed = [decoder decodeBoolForKey:@"Close Path"];

	NSString *version;
	version = [decoder decodeObjectForKey:@"Version"];

	NSArray *array;
	array = [decoder decodeObjectForKey:@"Points"];
	_points = malloc(_pointCount*sizeof(DBCurvePoint));
	
	NSEnumerator *e = [array objectEnumerator];
	NSString *pointString;
	NSNumber *num;
	int i = 0;
    

	while((pointString = [e nextObject])){
		_points[i].point = NSPointFromString(pointString);
		pointString = [e nextObject];
   		_points[i].controlPoint1 = NSPointFromString(pointString);
		pointString = [e nextObject];
		_points[i].controlPoint2 = NSPointFromString(pointString);
		num = [e nextObject];
		_points[i].hasControlPoints = [num boolValue];

		if([version isEqual:@"0.9"]){
			num = [e nextObject];
			_points[i].hasControlPoint1 = [num boolValue];
			num = [e nextObject];
			_points[i].hasControlPoint2 = [num boolValue];
		}
		
		num = [e nextObject];
		_points[i].closePath = [num boolValue];
		num = [e nextObject];
		_points[i].subPathStart = [num boolValue];
		
		i ++;
	}
	 
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:@"0.9" forKey:@"Version"];
	
	[encoder encodeInt:_pointCount forKey:@"Point count"];
	[encoder encodeBool:_lineIsClosed forKey:@"Close Path"];
	
	// create an NSArray of NSValues and fill it with the points
	
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4*_pointCount];
	NSString *pointString;
	
	int i;

	for( i = 0; i < _pointCount; i++ )
	{
		pointString = NSStringFromPoint(_points[i].point);
		[array addObject:pointString];

		pointString = NSStringFromPoint(_points[i].controlPoint1);
		[array addObject:pointString];
		
		pointString = NSStringFromPoint(_points[i].controlPoint2);
		[array addObject:pointString];
		
		[array addObject:[NSNumber numberWithBool:_points[i].hasControlPoints]];
		
		[array addObject:[NSNumber numberWithBool:_points[i].hasControlPoint1]]; // introduced in version 0.9
		[array addObject:[NSNumber numberWithBool:_points[i].hasControlPoint2]]; // introduced in version 0.9

		[array addObject:[NSNumber numberWithBool:_points[i].closePath]];
		[array addObject:[NSNumber numberWithBool:_points[i].subPathStart]];
		
	}
    
	[encoder encodeObject:array forKey:@"Points"];
	[array release];
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint controlPoint;
	BOOL controlPointSet;
	NSAutoreleasePool *pool;
	
	
	if([view isKindOfClass:[DBDrawingView class]])
	{		
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	
	[_path release];
	_path = nil;
	 
	_points = malloc(2*sizeof(DBCurvePoint));
	_points[0] = DBMakeCurvePoint(point);
	_points[0].subPathStart = YES;
	_points[1] = DBMakeCurvePoint(point);
	_pointCount = 2;
     
	_lineIsClosed = NO;
	
	[view setNeedsDisplay:YES];
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask | NSMouseMovedMask)];
		controlPointSet = NO;
		
		point = [view convertPoint:[theEvent locationInWindow] fromView:nil];  		
        
		[view moveMouseRulerMarkerWithEvent:theEvent];

		if([view isKindOfClass:[DBDrawingView class]])
		{
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
		if(distanceBetween(point, _points[0].point) <= 7/[(DBDrawingView *)view zoom]){
			point = _points[0].point;
		}else{

    	}
		
		if([theEvent type] == NSLeftMouseDown || [theEvent type] == NSRightMouseDown){

		
		  	if(DBPointIsOnKnobAtPointZoom(point,_points[0].point,[view zoom])){
				_lineIsClosed = YES;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(DBCurvePoint));
			
				_points[_pointCount-1].closePath = YES;
				[pool release];
				break;
			}
            
	 		if([theEvent clickCount] > 1){
				_lineIsClosed = NO;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(DBCurvePoint));
				[pool release];
				break;
			}

			_pointCount++;
		
			_points = realloc(_points,_pointCount*sizeof(DBCurvePoint));
		
			_points[_pointCount-2] = DBMakeCurvePoint(point);
			_points[_pointCount-1] = DBMakeCurvePoint(point);
            
		 	if(([theEvent modifierFlags] & NSControlKeyMask) || [theEvent type] == NSRightMouseDown)
			{
				_lineIsClosed = NO;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(DBCurvePoint));
				[pool release];
				break;
			}
        }else if([theEvent type] == NSLeftMouseDragged || [theEvent type] == NSLeftMouseUp){ 
		// control points

	        controlPoint = [view convertPoint:[theEvent locationInWindow] fromView:nil];
			point = _points[_pointCount-2].point;
			
			if([view isKindOfClass:[DBDrawingView class]])
			{
				controlPoint = [view pointSnapedToGrid:controlPoint];
				controlPoint = [view canevasCoordinatesFromViewCoordinates:controlPoint];
			}
	        
			_points[_pointCount-2].controlPoint1 = controlPoint;
			_points[_pointCount-2].controlPoint2 = NSMakePoint(2*point.x - controlPoint.x, 2*point.y - controlPoint.y);
			
			if([theEvent type] != NSLeftMouseUp){
				controlPointSet = YES;
				_points[_pointCount-2].hasControlPoints = YES;
				_points[_pointCount-2].hasControlPoint1 = YES;
				_points[_pointCount-2].hasControlPoint2 = YES;
			}
			//_points[_pointCount-1] = _points[_pointCount-2];
	    }else if([theEvent type] == NSMouseMoved){
 			_points[_pointCount-1] = DBMakeCurvePoint(point);
		}

//		[_layer updateRenderInView:view];
		[self updatePath];		
		[view setNeedsDisplay:YES];  
 		
		[pool release];
		
		
		
	}
	
	[self updatePath];
	[_layer updateRenderInView:view];
	
	_bounds = [_path bounds];
	
	return (_pointCount > 1);
}   

- (BOOL)editWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	NSPoint point;
	BOOL canConvert, didEdit;     
	int i;
	int controlPointIndex = -1;
	NSPoint p;
	NSPoint oldPoint;
	NSSize previousSize, newSize;
	NSAutoreleasePool *pool;
	float xOffset, yOffset;
	
	didEdit = NO;
	
	canConvert = [view isKindOfClass:[DBDrawingView class]];
   
	point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
  
	if(canConvert){
		// convert the cursor position so DO NOT SNAP TO GRID !!
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	
	for( i = 0; i < _pointCount; i++ )
	{		
//		if(_points[i].hasControlPoints){
			if(DBPointIsOnKnobAtPointZoom(point,_points[i].controlPoint1,[view zoom]))
			{   
				controlPointIndex = 1;
			}
			if(DBPointIsOnKnobAtPointZoom(point,_points[i].controlPoint2, [view zoom]))
			{   
				if(controlPointIndex == 1){ // point also on cp 1
					// get the nearest one
					controlPointIndex = (distanceBetween(p, _points[i].controlPoint1) <= distanceBetween(p, _points[i].controlPoint2) ) ? 1 : 2;
				}else{
					controlPointIndex = 2;
				}
			}
//		}
		if(DBPointIsOnKnobAtPointZoom(point, _points[i].point,[view zoom])) // priority to the main control point
		{   
			if(([theEvent modifierFlags] & NSShiftKeyMask) && controlPointIndex != -1){
				// if shift pressed then select cp 1 or 2
			}else{
				controlPointIndex = 0;
			}
		}
		
		if(controlPointIndex != -1) // control point found
			break;

   	}
	
	if(i >= _pointCount)
	{
		if([theEvent modifierFlags] & NSAlternateKeyMask){
		 	// add a point 

			DBCurvePoint nearestPoint, beforePt, afterPt;
			int seg;
			
			nearestPoint = [self nearestPointOfPathToPoint:point bezSegment:&seg beforePoint:&beforePt afterPoint:&afterPt];    

			if(seg != -1){
//				[self insertPoint:nearestPoint atIndex:seg+1 previousPoint:_points[seg] nextPoint:_points[seg+1]];
//				_points[seg].controlPoint1 = beforePt.controlPoint1;
//   				_points[seg+2].controlPoint2 = afterPt.controlPoint2;

				DBCurvePoint *newPoints = malloc((_pointCount) *sizeof(DBCurvePoint));
				
				int j;

				for( j = 0; j < _pointCount; j++ )
				{                     
					newPoints[j]= _points[j];
				}                            

				newPoints = insertCurvePointAtIndex(nearestPoint, seg+1, newPoints, _pointCount);
				newPoints[seg] = _points[seg];
				newPoints[seg+2] = _points[seg+1];
				newPoints[seg+1].closePath = NO;

				newPoints[seg].controlPoint1 = beforePt.controlPoint1;
				newPoints[seg+2].controlPoint2 = afterPt.controlPoint2;
				
				[self replacePoints:newPoints count:(_pointCount +1) type:DBInsertionReplacingType];
				
				[self updatePath];
				[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
				[_stroke updateStrokeForPath:_path]; 

				[_layer updateRenderInView:view];
   				[[[self layer] layerController] updateDependentLayers:[self layer]];

				[view setNeedsDisplay:YES];   			
			}
			
			return YES;
		}else{
			[self deselectAllPoints];
			[view setNeedsDisplay:YES];
			// no knob selected
			return [self changeFillImageDrawPointWithEvent:theEvent inView:view];
		}
	}else{
		if([theEvent modifierFlags] & NSShiftKeyMask){
			[self togglePointSelectionAtIndex:i];
		}else{
			if(![self pointAtIndexIsSelected:i]){
				[self deselectAllPoints];
				[self selectPointAtIndex:i];
			}
		}
	}
   
 
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
				
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
        
		[view moveMouseRulerMarkerWithEvent:theEvent];

		if(canConvert){
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
		
		xOffset = [theEvent deltaX];
		yOffset = [theEvent deltaY];

		if((xOffset*xOffset + yOffset*yOffset) >= 1){
			didEdit = YES;
			
			switch(controlPointIndex){
				case 0 :	oldPoint = _points[i].point;  _points[i].point = point; break;
				case 1 :	oldPoint = _points[i].controlPoint1;  _points[i].controlPoint1 = point; _points[i].hasControlPoint1 = YES; break;
				case 2 :	oldPoint = _points[i].controlPoint2;  _points[i].controlPoint2 = point; _points[i].hasControlPoint2 = YES; break;
				default : 	oldPoint = _points[i].point;  _points[i].point = point; break;
			}       
        

			if(controlPointIndex == 0){
				float deltaX, deltaY;

				deltaX = point.x - oldPoint.x;
				deltaY = point.y - oldPoint.y;
			
				_points[i].controlPoint1.x += deltaX;
				_points[i].controlPoint1.y += deltaY;
				_points[i].controlPoint2.x += deltaX;
				_points[i].controlPoint2.y += deltaY;
			}else if(controlPointIndex == 1){
				NSPoint curvePoint;
				NSPoint controlPoint, rotatedPoint;
				float angle;			
				curvePoint = _points[i].point;
            
	            if([theEvent modifierFlags] & NSAlternateKeyMask){

				}else if([theEvent modifierFlags] & NSControlKeyMask || NSEqualPoints(oldPoint, _points[i].point)){
					_points[i].controlPoint2 = NSMakePoint(2*curvePoint.x - point.x, 2*curvePoint.y - point.y);
				}else{
					if(!NSEqualPoints(_points[i].point, _points[i].controlPoint2) && !NSEqualPoints(oldPoint, _points[i].point)){
						angle = DBAngleBetweenPoints(curvePoint,oldPoint,_points[i].controlPoint1);
						controlPoint = _points[i].controlPoint2;
				
						controlPoint.x -= curvePoint.x;
						controlPoint.y -= curvePoint.y;

						rotatedPoint.x = controlPoint.x*cos(angle)-controlPoint.y*sin(angle);
						rotatedPoint.y = controlPoint.x*sin(angle)+controlPoint.y*cos(angle);
				

						rotatedPoint.x += curvePoint.x;
						rotatedPoint.y += curvePoint.y;
						_points[i].controlPoint2 = rotatedPoint;
					}
				}
			}else if(controlPointIndex == 2){  
				NSPoint curvePoint;
				NSPoint controlPoint, rotatedPoint;
				float angle;			
				curvePoint = _points[i].point;
            
	            if([theEvent modifierFlags] & NSAlternateKeyMask){
			
				}else if([theEvent modifierFlags] & NSControlKeyMask || NSEqualPoints(oldPoint, _points[i].point)){
	            	_points[i].controlPoint1 = NSMakePoint(2*curvePoint.x - point.x, 2*curvePoint.y - point.y);
		   		}else{
					if(!NSEqualPoints(_points[i].point, _points[i].controlPoint1) && !NSEqualPoints(oldPoint, _points[i].point)){
						angle = DBAngleBetweenPoints(curvePoint,oldPoint,_points[i].controlPoint2);
						controlPoint = _points[i].controlPoint1;
				
						controlPoint.x -= curvePoint.x;
						controlPoint.y -= curvePoint.y;

						rotatedPoint.x = controlPoint.x*cos(angle)-controlPoint.y*sin(angle);
						rotatedPoint.y = controlPoint.x*sin(angle)+controlPoint.y*cos(angle);
				

						rotatedPoint.x += curvePoint.x;
						rotatedPoint.y += curvePoint.y;
						_points[i].controlPoint1 = rotatedPoint;
					}
				}
			}   
		
			[self updatePath];
			[self updateBounds];
		
			newSize = _bounds.size;
		
			[_fill resizeFillFromSize:previousSize toSize:newSize];
			[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 


	//		[_layer updateRenderInView:view];
			[view setNeedsDisplay:YES];
		
			previousSize = newSize;
        
			[[[self layer] layerController] updateDependentLayers:[self layer]];
    	}
		[pool release];
		
		if([theEvent type] == NSLeftMouseUp)
		{
			break;
		}
	}
	
	if(didEdit){
		[[[[_layer layerController] documentUndoManager] prepareWithInvocationTarget:self] setPoint:_points[i] atIndex:i];
		[[[_layer layerController] documentUndoManager] setActionName:NSLocalizedString(@"Edit", nil)];
	}
	
	_bounds = [_path bounds];
	
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[_layer updateRenderInView:view];
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	
	[view setNeedsDisplay:YES];
	 	
	return YES;
}

- (BOOL)canEdit
{
	return YES;
}

- (BOOL)replaceInView:(DBDrawingView *)view
{
	if([_selectedPoints count] != 2){
		// not the good number of points
		return NO;
	}
	
	NSPoint point = [view convertPoint:[[view window] convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
	NSPoint controlPoint;
	NSEvent *theEvent;      
	BOOL controlPointSet;

	NSAutoreleasePool *pool;
	BOOL mouseOutside = NO;
	int index1, index2;

	if([view isKindOfClass:[DBDrawingView class]])
	{		
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	index1 =  [_selectedPoints firstIndex];
	index2 =  [_selectedPoints lastIndex];
	
	if(DBSubPathBegging(_points,index1) != DBSubPathBegging(_points,index2)){ // not on the same subpath
		return NO;
	}
	
	DBCurvePoint *oldPoints; int oldPointCount;
	oldPoints = malloc(_pointCount*sizeof(DBCurvePoint));
	oldPoints = memcpy(oldPoints, _points, _pointCount*sizeof(DBCurvePoint));
	oldPointCount = _pointCount;
	
	_oldPathFrag = [[self pathFragmentBetween:index1 and:index2] retain];
	[self deletePathBetween:index1 and:index2];
	index2 = index1 + 1;
	[self deselectAllPoints];
	
	_points = insertCurvePointAtIndex(DBMakeAnotherCurvePoint(point), index2, _points, _pointCount);
	_pointCount++;
	index2 ++; 
	
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];

		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask | NSMouseMovedMask)];

		[view moveMouseRulerMarkerWithEvent:theEvent];

        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
		
		
		mouseOutside = !NSPointInRect(point, [view bounds]);
		
		if([view isKindOfClass:[DBDrawingView class]])
		{
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
   
		if([theEvent window] && [theEvent window] != [view window]){
			_points = removeCurvePointAtIndex( index2-1, _points, _pointCount);
			_pointCount--;

  			[self updatePath];
			[self updateBounds];

			[pool release];
			break;   							

		}

  		if([theEvent type] == NSLeftMouseDown || [theEvent type] == NSRightMouseDown){

			if(mouseOutside){
				_points = removeCurvePointAtIndex( index2-1, _points, _pointCount);
				_pointCount--;
				[pool release];

	  			[self updatePath];
				[self updateBounds];

				break;   							
			}

	 		if([theEvent clickCount] > 1 || !NSPointInRect(point, [view bounds])){
				_points = removeCurvePointAtIndex( index2-1, _points, _pointCount);
				_pointCount--;
				[pool release];

	  			[self updatePath];
				[self updateBounds];

				break;
			}

			// _points = insertCurvePointAtIndex(point, index2-1, _points, _pointCount);
			// _pointCount++;
			// index2 ++; 

			[self updatePath];
			[self updateBounds];
			[view setNeedsDisplay:YES];


			if(([theEvent modifierFlags] & NSControlKeyMask) || [theEvent type] == NSRightMouseDown)
			{   
				_lineIsClosed = NO;
				_points = removeCurvePointAtIndex( index2-1, _points, _pointCount);
				_pointCount--;
				[pool release];
				break;
			}
		}else if([theEvent type] == NSLeftMouseDragged || [theEvent type] == NSLeftMouseUp){ 
		// control points

	        controlPoint = [view convertPoint:[theEvent locationInWindow] fromView:nil];
			point = _points[index2-1].point;
			
			if([view isKindOfClass:[DBDrawingView class]])
			{
				controlPoint = [view pointSnapedToGrid:controlPoint];
				controlPoint = [view canevasCoordinatesFromViewCoordinates:controlPoint];
			}
	        
			
			if([theEvent type] != NSLeftMouseUp){
				controlPointSet = YES;
				_points[_pointCount-2].hasControlPoints = YES;

				_points[index2-1].controlPoint1 = controlPoint;
				_points[index2-1].controlPoint2 = NSMakePoint(2*point.x - controlPoint.x, 2*point.y - controlPoint.y);
			}else{
				_points = insertCurvePointAtIndex(_points[index2-1], index2, _points, _pointCount);
  
  				_pointCount++;
				index2 ++;
			}
  
  			[self updatePath];
			[self updateBounds];
			[view setNeedsDisplay:YES];
			//_points[_pointCount-1] = _points[_pointCount-2];
	    }else if([theEvent type] == NSMouseMoved){

			NSPoint oldPoint = _points[index2-1].point;
			float dX, dY;
			dX = point.x-oldPoint.x;
			dY = point.y-oldPoint.y;       
			
			_points[index2-1].point.x += dX;
			_points[index2-1].point.y += dY;
			_points[index2-1].controlPoint1.x += dX;
			_points[index2-1].controlPoint1.y += dY;
			_points[index2-1].controlPoint2.x += dX;
			_points[index2-1].controlPoint2.y += dY;
			
			[self updatePath];
			[view setNeedsDisplay:YES];			 
		}
   		[pool release];
	}

	[_oldPathFrag release];
	_oldPathFrag = nil;

	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[_layer updateRenderInView:nil];
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	
	[view setNeedsDisplay:YES];
	
	DBUndoManager *undo = [[_layer layerController] documentUndoManager];
	[[undo prepareWithInvocationTarget:self] replacePoints:oldPoints count:oldPointCount type:DBFragReplaceReplacingType];
	[undo setActionName:NSLocalizedString(@"Replace Frag", nil)];
	
	return YES;
}

- (void)deletePathBetween:(int)index1 and:(int)index2
{
	DBCurvePoint * newPoints;
	
	int i, j;          
	int begin, end;
	begin = MIN(index1,index2);
	end = MAX(index1,index2);
	
	newPoints = malloc(sizeof(DBCurvePoint)* (_pointCount-(end - begin -1 ) ) );
   	
	for( i = 0 , j = 0; i < _pointCount; i++ )
	{
		if(i >= end || i <= begin){
			newPoints[j] = _points[i];
			j++;
		}
	}
	
	free(_points);
	_points = newPoints;
	_pointCount = _pointCount-(end - begin -1 ) ;
	
	[self updatePath];
	[self updateBounds];
}   

- (NSBezierPath *)pathFragmentBetween:(int)index1 and:(int)index2
{
	DBCurvePoint * points;
	
	int i, j;          
	int begin, end;
	begin = MIN(index1,index2);
	end = MAX(index1,index2);
	
	points = malloc(sizeof(DBCurvePoint)* (end - begin +1 ) );
   	
	for( i = 0 , j = 0; i < _pointCount; i++ )
	{
		if(i <= end && i >= begin){
			points[j] = _points[i];
			j++;
		}
	}
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	DBDrawingView *view;
	BOOL canConvert; 

	NSPoint point;
	NSPoint controlPoint1, controlPoint2;
	
	if ((end - begin +1 ) <= 0) {
   		return nil;
	}
	
	view = [[[self layer] layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	

	if(canConvert)
	{
		point = [view viewCoordinatesFromCanevasCoordinates:points[0].point];
   		controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:points[0].controlPoint1];
		controlPoint2 = [view viewCoordinatesFromCanevasCoordinates:points[0].controlPoint2];
	}

	[path moveToPoint:point];	
	
  	for( i = 1; i < (end - begin +1 ); i++ )
	{
		point = points[i].point;
		controlPoint1 = points[i-1].controlPoint1;
		controlPoint2 = points[i].controlPoint2;
		
		if(canConvert)
		{
			point = [view viewCoordinatesFromCanevasCoordinates:point];
			controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:controlPoint1];
			controlPoint2 = [view viewCoordinatesFromCanevasCoordinates:controlPoint2];
		}
		
		[path curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
  	}  

	return path;
}   

- (void)dealloc
{
	[_path release];
	_path = nil;
	[_controlPointsPath release];
	[_selectedPoints release];
	
	[super dealloc];
}
 
- (void)drawInView:(DBDrawingView *)view rect:(NSRect)rect
{
	if(!NSIsEmptyRect(rect) && !NSIntersectsRect(rect, _bounds) && !NSIsEmptyRect(_bounds)){
		return;
	}

   	if([[NSGraphicsContext currentContext] isKindOfClass:[NSBitmapGraphicsContext class]]){
		[_shadow reverseShadowOffsetHeight];
	}

	[NSGraphicsContext saveGraphicsState]; 
     
	[_shadow set];

	CGContextBeginTransparencyLayer([[NSGraphicsContext currentContext] graphicsPort],NULL);
	
	[self applyFillsToPath:_path];

	[[self stroke] strokePath:_path];
	[[self stroke] strokePath:_tempPath];

	CGContextEndTransparencyLayer([[NSGraphicsContext currentContext] graphicsPort]);

	[NSGraphicsContext restoreGraphicsState];

   	if([[NSGraphicsContext currentContext] isKindOfClass:[NSBitmapGraphicsContext class]]){
		[_shadow reverseShadowOffsetHeight];
	}
	
	[[NSColor greenColor] set];
	[_oldPathFrag stroke];
	
}

- (void)displayEditingKnobs
{
	int i;
	NSPoint p;
	BOOL canConvert;     
	DBDrawingView *view;
	
	view = [[[self layer] layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];

	for( i = 0; i < _pointCount; i++ )
	{    
		
		if(_points[i].hasControlPoint1){
			p = _points[i].controlPoint1;
			if(canConvert)
			{
				p = [view viewCoordinatesFromCanevasCoordinates:p];
			}
		
			[DBShape drawWhiteKnobAtPoint:p];
		}	
		
		if(_points[i].hasControlPoint2){
			p = _points[i].controlPoint2;
			if(canConvert)
			{
				p = [view viewCoordinatesFromCanevasCoordinates:p];
			}
		
			[DBShape drawWhiteKnobAtPoint:p];
		}
		p = _points[i].point;
		if(canConvert)
		{
			p = [view viewCoordinatesFromCanevasCoordinates:p];
		}
		
		if([self pointAtIndexIsSelected:i]){
			[DBShape drawSelectedGrayKnobAtPoint:p];
		}else{
			[DBShape drawGrayKnobAtPoint:p];
		}
   	
	}
	
	[[NSColor lightGrayColor] set];
	[_controlPointsPath stroke];	

	/*	if(([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) ){
	 p = [_fill imageDrawPoint];
	 p.x *= [self zoom];
	 p.x += _bounds.origin.x;
	 p.y *= [self zoom];
	 p.y += _bounds.origin.y;
	 
	 [[DBShape greenKnob] drawAtPoint:NSMakePoint(p.x-5.0,p.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];		
	 }*/
	
	[super displayEditingKnobs];
}

- (BOOL)hitTest:(NSPoint)point
{
	BOOL test;
	
	if([self isNaN]){
		return NO;		
	}
	
	test = [_path containsPoint:point];
	DBDrawingView *view = [[_layer layerController] drawingView];
	
    if(!test){
		int i;
		NSPoint p;
		
		if(view){
//			point = [[[[self layer] layerController] drawingView] canevasCoordinatesFromViewCoordinates:point];
		}
		
		for( i = 0; i < _pointCount; i++ )
		{    
			p = _points[i].point;
			if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]))
			{
				return YES;
			}
			p = _points[i].controlPoint1;
			if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]))
			{
				return YES;
			}
			p = _points[i].controlPoint2;
			if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]))
			{
				return YES;
			}
	   	}
	
		// no knob, so test the image draw point
		
		p = [_fill imageDrawPoint];
		p.x += _bounds.origin.x;
		p.y += _bounds.origin.y;

		if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]) && [_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode){
			return YES;
		}
		
	}
     
//	NSLog(@"test : %@, %@", NSStringFromPoint(point), NSStringFromRect(_bounds));
  
  	return test;
} 

- (void)updateShape
{
	[super updateShape];
	[self updatePath];
}

- (void)updatePath
{
	DBDrawingView *view;
	BOOL canConvert; 

	int i;
	int beginningPoint;
	NSPoint point;
	NSPoint controlPoint1, controlPoint2, controlPoint3;
	
	if (_pointCount <= 0) {
		[_path release];
		_path = nil;
		return;
	}
	
	view = [[[self layer] layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	
	[_path release];
  	_path = [[NSBezierPath bezierPath] retain];
	[_controlPointsPath release];
  	_controlPointsPath = [[NSBezierPath bezierPath] retain];

	point = _points[0].point;
	controlPoint1 = _points[0].controlPoint1;
	controlPoint2 = _points[0].controlPoint2;
	
	if(canConvert)
	{
		point = [view viewCoordinatesFromCanevasCoordinates:point];
		controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:controlPoint1];
		controlPoint2 = [view viewCoordinatesFromCanevasCoordinates:controlPoint2];
	}

	[_path moveToPoint:point];
	[_controlPointsPath moveToPoint:controlPoint1];
	[_controlPointsPath lineToPoint:point];
	[_controlPointsPath lineToPoint:controlPoint2];
		
	beginningPoint = 0;
	
  	for( i = 1; i < _pointCount; i++ )
	{
		point = _points[i].point;
		controlPoint1 = _points[i-1].controlPoint1;
		controlPoint2 = _points[i].controlPoint2;
		controlPoint3 = _points[i].controlPoint1;
		
		if(canConvert)
		{
			point = [view viewCoordinatesFromCanevasCoordinates:point];
			controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:controlPoint1];
			controlPoint2 = [view viewCoordinatesFromCanevasCoordinates:controlPoint2];
			controlPoint3 = [view viewCoordinatesFromCanevasCoordinates:controlPoint3];
		}

		[_controlPointsPath moveToPoint:controlPoint3];
		[_controlPointsPath lineToPoint:point];
		[_controlPointsPath lineToPoint:controlPoint2];			
		
		if(_points[i].subPathStart){
			[_path moveToPoint:point];
			beginningPoint = i;
			
		}else{
			
			if(!_points[i-1].hasControlPoint1 && !_points[i].hasControlPoint2){
				[_path lineToPoint:_points[i].point];
			}else if (!_points[i-1].hasControlPoint1) {
				[_path curveToPoint:point controlPoint1:controlPoint2 controlPoint2:controlPoint2];
			}else if (!_points[i].hasControlPoint2) {
				[_path curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint1];
			}else{
				[_path curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
			}
			
			controlPoint1 = _points[i].controlPoint1;
			if(canConvert)
			{
				controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:controlPoint1];
			}
			[_controlPointsPath moveToPoint:controlPoint1];
			[_controlPointsPath lineToPoint:point];
			[_controlPointsPath lineToPoint:controlPoint2];
			
			
			if(_points[i].closePath){
				point = _points[beginningPoint].point;
				controlPoint1 = _points[i].controlPoint1;
				controlPoint2 = _points[beginningPoint].controlPoint2;
				
				if(canConvert)
				{
					point = [view viewCoordinatesFromCanevasCoordinates:point];
					controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:controlPoint1];
					controlPoint2 = [view viewCoordinatesFromCanevasCoordinates:controlPoint2];
				}
				
				if(!_points[i].hasControlPoint1 && !_points[beginningPoint].hasControlPoint2){
					[_path lineToPoint:_points[i].point];
				}else if (!_points[i].hasControlPoint1) {
					[_path curveToPoint:point controlPoint1:controlPoint2 controlPoint2:controlPoint2];
				}else if (!_points[beginningPoint].hasControlPoint2) {
					[_path curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint1];
				}else{
					[_path curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
				}

				[_path closePath];				
			}
		}
	}  
	
//	if(_lineIsClosed){
//		point = _points[0].point;
//		controlPoint1 = _points[_pointCount-1].controlPoint1;
//		controlPoint2 = _points[0].controlPoint2;
//		
//		if(canConvert)
//		{
//			point = [view viewCoordinatesFromCanevasCoordinates:point];
//			controlPoint1 = [view viewCoordinatesFromCanevasCoordinates:controlPoint1];
//			controlPoint2 = [view viewCoordinatesFromCanevasCoordinates:controlPoint2];
//		}
//		
//		[_path curveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
//		[_path closePath];
//	} 
	
//	_bounds = [_path bounds];
}

- (void)updateBounds
{
	_bounds = [_path bounds];
}   

- (void)strokeUpdated
{
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[super strokeUpdated];
}

- (void)rotate:(float)deltaRot
{
	int i;
	NSPoint p;
	NSPoint rotatedPoint;
	NSPoint rotationCenter;
	
	rotationCenter = [self rotationCenter];
	
	// convert in radian
	deltaRot = (M_PI/180)*deltaRot;
	
   	for( i = 0; i < _pointCount; i++ )
	{    
		p = _points[i].point;
		
		p.x -= rotationCenter.x;
		p.y -= rotationCenter.y;

		rotatedPoint.x = p.x*cos(deltaRot)-p.y*sin(deltaRot);
		rotatedPoint.y = p.x*sin(deltaRot)+p.y*cos(deltaRot);

		rotatedPoint.x += rotationCenter.x;
		rotatedPoint.y += rotationCenter.y;
		
		_points[i].point = rotatedPoint;

		p = _points[i].controlPoint1;
		
		p.x -= rotationCenter.x;
		p.y -= rotationCenter.y;

		rotatedPoint.x = p.x*cos(deltaRot)-p.y*sin(deltaRot);
		rotatedPoint.y = p.x*sin(deltaRot)+p.y*cos(deltaRot);

		rotatedPoint.x += rotationCenter.x;
		rotatedPoint.y += rotationCenter.y;
		
		_points[i].controlPoint1= rotatedPoint;

		p = _points[i].controlPoint2;
		
		p.x -= rotationCenter.x;
		p.y -= rotationCenter.y;

		rotatedPoint.x = p.x*cos(deltaRot)-p.y*sin(deltaRot);
		rotatedPoint.y = p.x*sin(deltaRot)+p.y*cos(deltaRot);

		rotatedPoint.x += rotationCenter.x;
		rotatedPoint.y += rotationCenter.y;
		
		_points[i].controlPoint2= rotatedPoint;
  	}
   	
	[self updatePath];
	_bounds = [_path bounds];

	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

}

- (void)moveByX:(float)deltaX byY:(float)deltaY
{
	[super moveByX:deltaX byY:deltaY];
	
	int i;
	NSPoint p;
		
   	for( i = 0; i < _pointCount; i++ )
	{    
		p = _points[i].point;
		p.x += deltaX;
		p.y += deltaY;
 		_points[i].point = p;
		p = _points[i].controlPoint1;
		p.x += deltaX;
		p.y += deltaY;
 		_points[i].controlPoint1 = p;
		p = _points[i].controlPoint2;
		p.x += deltaX;
		p.y += deltaY;
 		_points[i].controlPoint2 = p;
  	}
   	
	[self updatePath];
	_bounds = [_path bounds];
	
//	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

}

- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags
{
	int newKnob = 0;
	newKnob = [super resizeByMovingKnob:knob fromPoint:fromPoint toPoint:point inView:view modifierFlags:flags];  
	
	[self putPathInRect:_bounds];	
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 


	return newKnob;
}

- (void)flipVerticallyWithNewKnob:(int)knob
{
	int i;
	NSPoint p;

	for( i = 0; i < _pointCount; i++ )
	{    
		p = _points[i].point;
	   	p.x -= _bounds.origin.x;
		p.x = -p.x;
		p.x += _bounds.origin.x;
		_points[i].point = p;
		p = _points[i].controlPoint1;
	   	p.x -= _bounds.origin.x;
		p.x = -p.x;
		p.x += _bounds.origin.x;
		_points[i].controlPoint1 = p;
		p = _points[i].controlPoint2;
	   	p.x -= _bounds.origin.x;
		p.x = -p.x;
		p.x += _bounds.origin.x;
		_points[i].controlPoint2 = p;
	}

	[self updatePath];

}

- (void)flipHorizontalyWithNewKnob:(int)knob
{
	int i;
	NSPoint p;

	for( i = 0; i < _pointCount; i++ )
	{    
		p = _points[i].point;
	   	p.y -= _bounds.origin.y;
		p.y = -p.y;
		p.y += _bounds.origin.y;
		_points[i].point = p;
		
		p = _points[i].controlPoint1;
	   	p.y -= _bounds.origin.y;
		p.y = -p.y;
		p.y += _bounds.origin.y;
		_points[i].controlPoint1 = p;
		
		p = _points[i].controlPoint2;
	   	p.y -= _bounds.origin.y;
		p.y = -p.y;
		p.y += _bounds.origin.y;
		_points[i].controlPoint2 = p;
	}

	[self updatePath];
}

- (void)putPathInRect:(NSRect)newRect
{
	if(newRect.size.width == 0 || newRect.size.height == 0){
		return;
	} 
	
	NSRect oldRect;
	
	oldRect = [_path bounds];
	
	int i;
	NSPoint p;
	float xFactor, yFactor;
	
	xFactor = newRect.size.width / oldRect.size.width; 
	yFactor = newRect.size.height / oldRect.size.height;


    for( i = 0; i < _pointCount; i++ )
 	{    
 		p = _points[i].point;
    	p.x -= oldRect.origin.x;
    	p.y -= oldRect.origin.y;
		p.x *= xFactor;
		p.y *= yFactor;
    	p.x += newRect.origin.x;
    	p.y += newRect.origin.y;
  		_points[i].point= p;

 		p = _points[i].controlPoint1;
    	p.x -= oldRect.origin.x;
    	p.y -= oldRect.origin.y;
		p.x *= xFactor;
		p.y *= yFactor;
    	p.x += newRect.origin.x;
    	p.y += newRect.origin.y;
  		_points[i].controlPoint1= p; 

 		p = _points[i].controlPoint2;
    	p.x -= oldRect.origin.x;
    	p.y -= oldRect.origin.y;
		p.x *= xFactor;
		p.y *= yFactor;
    	p.x += newRect.origin.x;
    	p.y += newRect.origin.y;
  		_points[i].controlPoint2= p;
   	}

 	[self updatePath];
	[self updateBounds];
	
	[_fill resizeFillFromSize:oldRect.size toSize:newRect.size];
}

- (NSBezierPath *)path
{
	return _path;
}              

- (void)setPoint:(DBCurvePoint)p atIndex:(int)i
{
	[[[[_layer layerController] documentUndoManager] prepareWithInvocationTarget:self] setPoint:_points[i] atIndex:i];
	[[[_layer layerController] documentUndoManager] setActionName:NSLocalizedString(@"Edit", nil)];
	
	_points[i] = p;                 
	[self updatePath];
	[self updateBounds];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
}

#pragma mark Points Selection
- (void)deselectAllPoints
{
	[_selectedPoints removeAllIndexes];
}   

- (void)selectPointAtIndex:(int)index
{
   	if(![self pointAtIndexIsSelected:index]){
		[_selectedPoints addIndex:index];
   	}
}   

- (void)deselectPointAtIndex:(int)index
{
   	if([self pointAtIndexIsSelected:index]){
		[_selectedPoints removeIndex:index];
   	}
}   

- (void)togglePointSelectionAtIndex:(int)index
{
   	if([self pointAtIndexIsSelected:index]){
		[self deselectPointAtIndex:index];
   	}else{
		[self selectPointAtIndex:index];
   	}	
}                       

- (BOOL)pointAtIndexIsSelected:(int)index
{
	return [_selectedPoints containsIndex:index];
}

#pragma mark Actions
- (void)addPoint:(id)sender
{
	int addedPoints = 0;
	DBCurvePoint newPoint;
	DBCurvePoint *newPoints = malloc(_pointCount*sizeof(DBCurvePoint));
	int newPointCount = _pointCount;
	
	NSPoint bez[4], bez1[4], bez2[4];
  	int i;
    
	// copy points
	
	for( i = 0; i < _pointCount; i++ )
	{
		newPoints[i] = _points[i];
	}                             
	
	int subPathStart = 0, newSubPathStart = 0;
	
	for (i = 0; i < _pointCount; i++) {
		if(_points[i].subPathStart){
			subPathStart = i;
			newSubPathStart = i+addedPoints;
		}
		
		if([_selectedPoints containsIndex:i]){
			if([_selectedPoints containsIndex:i+1] && _points[i+1].subPathStart == NO){
				// add a point
				bez[0] = _points[i].point;
				bez[1] = _points[i].controlPoint1;
				bez[2] = _points[i+1].controlPoint2;
				bez[3] = _points[i+1].point;
				
				subdivideBezier(bez,bez1,bez2);
				
				newPoints[i+addedPoints].controlPoint1 = bez1[1];
				newPoint.controlPoint2 = bez1[2];
				newPoint.point = bez1[3];
				newPoint.controlPoint1 = bez2[1];
				newPoint.subPathStart = NO;
				newPoint.closePath = NO;
				newPoints[i+addedPoints+1].controlPoint2 = bez2[2];
				
				// insert the new point
				newPoints = insertCurvePointAtIndex(newPoint,i+addedPoints+1, newPoints, newPointCount);
				
				newPointCount++;
				addedPoints++;
			}else if (_points[i].closePath && [_selectedPoints containsIndex:subPathStart]) {
				bez[0] = _points[i].point;
				bez[1] = _points[i].controlPoint1;
				bez[2] = _points[subPathStart].controlPoint2;
				bez[3] = _points[subPathStart].point;
				
				subdivideBezier(bez,bez1,bez2);
				
				newPoints[i+addedPoints].controlPoint1 = bez1[1];
				newPoints[i+addedPoints].closePath = NO;

				newPoint.controlPoint2 = bez1[2];
				newPoint.point = bez1[3];
				newPoint.controlPoint1 = bez2[1];
				newPoint.subPathStart = NO;
				newPoint.closePath = YES;
				newPoints[newSubPathStart].controlPoint2 = bez2[2];
				
				// insert the new point
				newPoints = insertCurvePointAtIndex(newPoint,i+addedPoints+1, newPoints, newPointCount);
				
				newPointCount++;
				addedPoints++;
				
			}
		}
	}
	
	[self deselectAllPoints];
    
	if(addedPoints > 0){
		[self replacePoints:newPoints count:newPointCount type:DBInsertionReplacingType];
		
		[self updatePath];
		[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
		[_stroke updateStrokeForPath:_path]; 
		
		[_layer updateRenderInView:nil];
		[[[self layer] layerController] updateDependentLayers:[self layer]];
		
		[[[_layer layerController] drawingView] setNeedsDisplay:YES];		
	}
}


- (void)delete:(id)sender
{
	// delete selected points
	DBCurvePoint *newPoints;
	int i, j;
	
	newPoints = malloc(sizeof(DBCurvePoint)*(_pointCount-[_selectedPoints count]));
   	
	for( i = 0, j = 0; i < _pointCount; i++ )
	{
		if(![_selectedPoints containsIndex:i]){
			newPoints[j] = _points[i];
			j++;
		}
	}
	
	[self replacePoints:newPoints count:(_pointCount - [_selectedPoints count]) type:DBDeletionReplacingType];
}

#pragma mark Point insertion routines

- (DBCurvePoint)nearestPointOfPathToPoint:(NSPoint)point bezSegment:(int *)seg beforePoint:(DBCurvePoint *)beforePt afterPoint:(DBCurvePoint *)afterPt
{
	NSPoint bez[4], bez1[4], bez2[4];
	int count = 0;
	int i, index = -1;
	float length, nearestLength, bezLength; 
	float lengthFromBegining;
	DBCurvePoint nearest, before, after;
	float nearestDist,dist, dX, dY;
	          
	nearest = DBMakeCurvePoint(NSMakePoint(NSNotFound, NSNotFound));
	
	before = *beforePt;
	after = *afterPt;
	
	nearestDist = 100.0 ; // 10 pixels tolerance

	
	dX = point.x - _points[0].point.x; dY = point.y - _points[0].point.y;
	dist = (dX*dX + dY*dY);
	
	if(nearestDist > dist){
		nearest = _points[0];		
		index = 0;  
		nearestDist = dist;
		nearestLength = 0.0;
		lengthFromBegining = 0.0;
	}
	
	count = 1;
	
	// first step : enter the loop to enumerate the bezier

	for( i = 0; i < _pointCount-1; i++ )
	{
	
		// second step : cut the bezier
		 
		bez[0] = _points[i].point;
		bez[1] = _points[i].controlPoint1;
		bez[2] = _points[i+1].controlPoint2;
		bez[3] = _points[i+1].point;
		
		length = lengthOfBezier(bez, DB_BEZIER_ERROR);
		bezLength = length;
		
		lengthFromBegining = 0.0;
		
   		while(length > 0.0){
			
			// subdivide : save the first part and put the other as the old one
			subdivideBezierAtLength(bez,bez1,bez2,DB_BEZIER_SEG_LENGTH,DB_BEZIER_ERROR);
			
			length -= DB_BEZIER_SEG_LENGTH;
			lengthFromBegining += DB_BEZIER_SEG_LENGTH;
			count ++;                                           
			   			
			// third step determine if it's closer
			
			dX = point.x - bez1[3].x; dY = point.y - bez1[3].y;
 			dist = (dX*dX + dY*dY);
 
			if(nearestDist > dist){     
				nearest.controlPoint2 = bez1[2];
				nearest.point = bez1[3];
				nearest.controlPoint1 = bez2[1];
				
				nearestDist = dist;
				index = i;
				
				nearestLength = bezLength - length;
				nearestLength = lengthFromBegining;
   			}

			bez[0] = bez2[0];
			bez[1] = bez2[1];
			bez[2] = bez2[2];
			bez[3] = bez2[3];
		} 
		
	}
	
	// don't forget to do it for the last bezier part if line is closed
	
	if(_lineIsClosed){
		bez[0] = _points[_pointCount-1].point;
		bez[1] = _points[_pointCount-1].controlPoint1;
		bez[2] = _points[0].controlPoint2;
		bez[3] = _points[0].point;
		
		length = lengthOfBezier(bez, DB_BEZIER_ERROR);
		bezLength = length;
		
		lengthFromBegining = 0.0;
   	
    	while(length > 0.0){
			
			// subdivide : save the first part and put the other as the old one
			subdivideBezierAtLength(bez,bez1,bez2,DB_BEZIER_SEG_LENGTH,DB_BEZIER_ERROR);
			
			length -= DB_BEZIER_SEG_LENGTH;
			
			count ++;

// 			segments = realloc(segments, sizeof(NSPoint)*count);			
//			segments[count-1] = bez1[3];
   			
			// third step determine if it's closer
			
			dX = point.x - bez1[3].x; dY = point.y - bez1[3].y;
 			dist = sqrt(dX*dX + dY*dY);
 
			if(nearestDist > dist){
				nearest.controlPoint2 = bez1[2];
    			nearest.point = bez1[3];
				nearest.controlPoint1 = bez2[1];

				nearestDist = dist;
				index = _pointCount;
				
				nearestLength = bezLength - length;
				nearestLength = lengthFromBegining;
			}

			bez[0] = bez2[0];
			bez[1] = bez2[1];
			bez[2] = bez2[2];
			bez[3] = bez2[3];
		} 
	}
	
	
	// last step : determine the half-tangents
	
	if(index != -1){		
		if(index == _pointCount){
			bez[0] = _points[index].point;
			bez[1] = _points[index].controlPoint1;
			bez[2] = _points[0].controlPoint2;
			bez[3] = _points[0].point;
		
			subdivideBezierAtLength(bez,bez1,bez2,nearestLength,DB_BEZIER_ERROR);
		
	 		before.controlPoint1 = bez1[1];
	   		nearest.controlPoint2 = bez1[2];
	 //   	nearest.point = bez1[3];
			nearest.controlPoint1 = bez2[1];
			after.controlPoint2 = bez2[2];		
		
		}else{
			bez[0] = _points[index].point;
			bez[1] = _points[index].controlPoint1;
			bez[2] = _points[index+1].controlPoint2;
			bez[3] = _points[index+1].point;
		
			subdivideBezierAtLength(bez,bez1,bez2,nearestLength,DB_BEZIER_ERROR);
		
			before.controlPoint1 = bez1[1];
			nearest.controlPoint2 = bez1[2];
	//		nearest.point = bez1[3];
			nearest.controlPoint1 = bez2[1];
			after.controlPoint2 = bez2[2];		
		
		}
	}

  	*seg = index;
	*beforePt = before;
	*afterPt = after; 
	
	return nearest;
}

- (NSPoint)nearestPointOfPath:(NSPoint)point
{
	NSPoint *pathPoints;
	int count;
	
//	pathPoints = [self cutPathInSegmentCount:&count];
	
	return nearestPointInArray(pathPoints,count,point);
}

- (void)removePointAtIndex:(int)index previousPoint:(DBCurvePoint)previous nextPoint:(DBCurvePoint)next
{
	DBUndoManager *undo = [[_layer layerController] documentUndoManager];
	[[undo prepareWithInvocationTarget:self] insertPoint:_points[index] atIndex:index previousPoint:_points[index-1] nextPoint:_points[index+1]];
	if(![undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Delete Point", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Insert Point", nil)];	
	}
	
	_points[index-1] = previous;
	_points[index+1] = next;
	_points = removeCurvePointAtIndex(index, _points, _pointCount);
	_pointCount--; 
	
	[self updatePath];
	[self updateBounds];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];	
}   

- (void)insertPoint:(DBCurvePoint)point atIndex:(int)index previousPoint:(DBCurvePoint)previous nextPoint:(DBCurvePoint)next
{
	DBUndoManager *undo = [[_layer layerController] documentUndoManager];
	[[undo prepareWithInvocationTarget:self] removePointAtIndex:index previousPoint:_points[index-1] nextPoint:_points[index]];
	if(![undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Insert Point", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Delete Point", nil)];	
	}
	
	_points = insertCurvePointAtIndex(point, index, _points, _pointCount);
	_pointCount++; 
	_points[index-1] = previous;
	_points[index+1] = next;
	
	[self updatePath];
	[self updateBounds];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
	
}

- (void)replacePoints:(DBCurvePoint *)points count:(int)count type:(int)replacingType
{
	DBUndoManager *undo = [[_layer layerController] documentUndoManager];
	[[undo prepareWithInvocationTarget:self] replacePoints:_points count:_pointCount type:replacingType];
	if(replacingType == DBInsertionReplacingType){
		[undo setActionName:NSLocalizedString(@"Insert Point", nil)];
	}else if(replacingType == DBDeletionReplacingType){
		[undo setActionName:NSLocalizedString(@"Delete Point", nil)];	
	}else if(replacingType == DBFragReplaceReplacingType){
		[undo setActionName:NSLocalizedString(@"Replace Frag", nil)];
	}
	
	_pointCount = count;
	_points = points;
	 
	[self updatePath];
	[self updateBounds];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
}

#pragma mark Transform 

- (void)applyTransform:(NSAffineTransform *)at
{
	int i;
	
	for (i = 0; i < _pointCount; i++) {
		_points[i].point = [at transformPoint:_points[i].point];
		_points[i].controlPoint1 = [at transformPoint:_points[i].controlPoint1];
		_points[i].controlPoint2 = [at transformPoint:_points[i].controlPoint2];
	}
	
	[self updateShape];
}

@end
