//
//  DBPolyline.m
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBPolyline.h"

#import "AJHBezierUtils.h"

@class NSBitmapGraphicsContext;

static double distanceBetween(NSPoint a, NSPoint b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  return sqrt (dx * dx + dy * dy);
}

NSPoint * insertPointAtIndex(NSPoint newPoint, int index, NSPoint *points, int pointsCount)
{
	NSPoint *newPoints;
	newPoints = malloc(sizeof(NSPoint)*(pointsCount+1));
                
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

NSPoint * removePointAtIndex( int index, NSPoint *points, int pointsCount)
{
	NSPoint *newPoints;
	newPoints = malloc(sizeof(NSPoint)*(pointsCount-1));
                
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

@implementation DBPolyline 
- (id)init
{
	self = [super init];
	            
	_selectedPoints = [[NSMutableIndexSet alloc] init];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	            	
	_pointCount = [decoder decodeIntForKey:@"Point count"];
	_lineIsClosed = [decoder decodeBoolForKey:@"Close Path"];

	NSArray *array;
	array = [decoder decodeObjectForKey:@"Points"];
	_points = malloc(_pointCount*sizeof(NSPoint));
	
	NSEnumerator *e = [array objectEnumerator];
	NSString *pointString;
	int i = 0;

	while((pointString = [e nextObject])){
		_points[i] = NSPointFromString(pointString);
		i ++;
	}
	 
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeInt:_pointCount forKey:@"Point count"];
	[encoder encodeBool:_lineIsClosed forKey:@"Close Path"];
	
	// create an NSArray of NSValues and fill it with the points
	
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:_pointCount];
	NSString *pointString;
	
	int i;

	for( i = 0; i < _pointCount; i++ )
	{
		pointString = NSStringFromPoint(_points[i]);
		[array insertObject:pointString atIndex:i];
	}
	[encoder encodeObject:array forKey:@"Points"];
	[array release];
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	NSAutoreleasePool *pool;
	BOOL mouseOutside = NO;
	if(!NSPointInRect(point, [view bounds])){
		return NO;
	}
	if([view isKindOfClass:[DBDrawingView class]])
	{		
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	

	[_path release];
	_path = nil;
	
	_points = malloc(2*sizeof(NSPoint));
	_points[0] = point;
	_points[1] = point; 
	
	
	_pointCount = 2;
     
	_lineIsClosed = NO;
	
	[view setNeedsDisplay:YES];

	// NSModalSession session = [NSApp beginModalSessionForWindow:[view window]];
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSMouseMovedMask)];
//		theEvent = [NSApp nextEventMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSMouseMovedMask) untilDate:nil inMode:NSModalPanelRunLoopMode dequeue:YES];
		[view moveMouseRulerMarkerWithEvent:theEvent];
		
		if([theEvent window] && [theEvent window] != [view window]){
			_lineIsClosed = NO;
			_pointCount--;
			_points = realloc(_points,_pointCount*sizeof(NSPoint));
			[pool release];
			break;   							
						
		}

        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
		
		
		mouseOutside = !NSPointInRect(point, [view bounds]);
		
		if([view isKindOfClass:[DBDrawingView class]])
		{
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}

		if(distanceBetween(point, _points[0]) <= 7/[(DBDrawingView *)view zoom]){ // 7 pixels on screen
			point = _points[0];
		}else{

    	}
		////NSLog(@"add point to polyline");
  		if([theEvent type] == NSLeftMouseDown || [theEvent type] == NSRightMouseDown){
    	  	if(DBPointIsOnKnobAtPointZoom(point,_points[0],[view zoom])){
				_lineIsClosed = YES;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(NSPoint));
				[pool release];
				break;
			}
	        
			if(mouseOutside){
				_lineIsClosed = NO;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(NSPoint));
				[pool release];
				break;   							
			}
		
	 		if([theEvent clickCount] > 1 || !NSPointInRect(point, [view bounds])){
				_lineIsClosed = NO;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(NSPoint));
				[pool release];
				break;
			}

			_pointCount++;

			_points = realloc(_points,_pointCount*sizeof(NSPoint));

			_points[_pointCount-2] = point;
			_points[_pointCount-1] = point;

			[self updatePath];
			[view setNeedsDisplay:YES];
       
    	
			if(([theEvent modifierFlags] & NSControlKeyMask) || [theEvent type] == NSRightMouseDown)
			{   
				_lineIsClosed = NO;
				_pointCount--;
				_points = realloc(_points,_pointCount*sizeof(NSPoint));
				[pool release];                    
				break;
			}
		}else if([theEvent type] == NSMouseMoved){ 
			_points[_pointCount-1] = point;
			
			[self updatePath];
			[view setNeedsDisplay:YES];			 
		}
   		[pool release];
	}
	
	// [NSApp endModalSession:session];
	
	[self updatePath];
	
	_bounds = [_path bounds];
	_boundsSize = _bounds.size;

	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[_layer updateRenderInView:view];
	
	return (_pointCount > 1);
}   

- (BOOL)editWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	NSPoint point;
	BOOL canConvert, didEdit;     
	int i;
	NSPoint p, previousPosition;
	NSSize previousSize, newSize;
	NSAutoreleasePool *pool;
	float xOffset, yOffset;
	
	didEdit = NO;
	canConvert = [view isKindOfClass:[DBDrawingView class]];
   
	point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
  
	if(canConvert){
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}

	for( i = 0; i < _pointCount; i++ )
	{    
		p = _points[i];
		
		if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]))
		{
			break;
		}
   	}
	
	if(i >= _pointCount)
	{                      
		if([theEvent modifierFlags] & NSAlternateKeyMask){
		 	// add a point 

			NSPoint nearestPoint[1];
			int seg;
			
			nearestPoint[0] = [self nearestPointOfPathToPoint:point segment:&seg];    

			if(seg != -1){
				[self insertPoints:nearestPoint atIndexes:[NSIndexSet indexSetWithIndex:seg+1]];
				
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
		
			// no knob is selected
			// try the fill image draw point
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
    
	previousPosition = _points[i];

	previousSize = _bounds.size;
	     
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
			
			_points[i] = point;

			[self updatePath];
			[self updateBounds];

			newSize = _bounds.size;

			[_fill resizeFillFromSize:previousSize toSize:newSize];
			[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 


	//		[_layer updateRenderInView:view];
			[view setNeedsDisplay:YES];

			previousSize = newSize;
		} 
        
		[pool release];
		
		if([theEvent type] == NSLeftMouseUp)
		{
			break;
		}
	}
	
	if(didEdit){
		[[[[_layer layerController] documentUndoManager] prepareWithInvocationTarget:self] setPoint:previousPosition atIndex:i];
		[[[_layer layerController] documentUndoManager] setActionName:NSLocalizedString(@"Edit", nil)];		
	}
	
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[_layer updateRenderInView:nil];
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
	if([_selectedPoints count] != 2 /*&& [_selectedPoints count] != 3*/ ){
		// not the good number of points
		return NO;
	}
	
	NSPoint point = [view convertPoint:[[view window] convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
	NSEvent *theEvent;      

	NSAutoreleasePool *pool;
	BOOL mouseOutside = NO;
//	int index1, index2;
	int indexes [3];

	if([view isKindOfClass:[DBDrawingView class]])
	{		
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	
	if([_selectedPoints count] == 2){
		indexes[0] =  [_selectedPoints firstIndex];
		indexes[1] =  [_selectedPoints lastIndex];		
	}else{
//		[_selectedPoints getIndexes:indexes maxCount:3 inIndexRange:nil];
   	}                                        
	                                        
	
	_oldPathFrag = [[self pathFragmentBetween:indexes[0] and:indexes[1]] retain];
	[self deletePathBetween:indexes[0] and:indexes[1]];
	indexes[1] = indexes[0] + 1;
	[self deselectAllPoints];
	
	_points = insertPointAtIndex(point, indexes[1], _points, _pointCount);
	_pointCount++;
	indexes[1] ++; 
	
	
	while(YES){

		pool = [[NSAutoreleasePool alloc] init];

		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSMouseMovedMask)];
		[view moveMouseRulerMarkerWithEvent:theEvent];

        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
		
		
		mouseOutside = !NSPointInRect(point, [view bounds]);
		
		if([view isKindOfClass:[DBDrawingView class]])
		{
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
   
		if([theEvent window] && [theEvent window] != [view window]){
			_points = removePointAtIndex( indexes[1] -1, _points, _pointCount);
			_pointCount--;
			[pool release];
			break;   							

		}

  		if([theEvent type] == NSLeftMouseDown || [theEvent type] == NSRightMouseDown){

			if(mouseOutside){
				_points = removePointAtIndex( indexes[1]-1, _points, _pointCount);
				_pointCount--;
				[pool release];
				break;   							
			}

	 		if([theEvent clickCount] > 1 || !NSPointInRect(point, [view bounds])){
				_points = removePointAtIndex( indexes[1]-1, _points, _pointCount);
				_pointCount--;
				[pool release];
				break;
			}

			_points = insertPointAtIndex(point, indexes[1]-1, _points, _pointCount);
			_pointCount++;
			indexes[1] ++; 

			[self updatePath];
			[self updateBounds];
			[view setNeedsDisplay:YES];


			if(([theEvent modifierFlags] & NSControlKeyMask) || [theEvent type] == NSRightMouseDown)
			{   
				_lineIsClosed = NO;
				_points = removePointAtIndex( indexes[1]-1, _points, _pointCount);
				_pointCount--;
				[pool release];
				break;
			}
		}else if([theEvent type] == NSMouseMoved){
			_points[indexes[1]-1] = point;
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
	
	
	return YES;
}

- (void)deletePathBetween:(int)index1 and:(int)index2
{
	NSPoint * newPoints;
	
	int i, j;          
	int begin, end;
	begin = MIN(index1,index2);
	end = MAX(index1,index2);
	
	newPoints = malloc(sizeof(NSPoint)* (_pointCount-(end - begin -1 ) ) );
   	
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

/*- (void)deletePathContaining:(int [3])indexes
{
	if(_lineIsClosed){
		[self deletePathBetween:MAX(indexes[0], MAX(indexes[1], indexes[2])) and:MIN(indexes[0], MIN(indexes[1], indexes[2]))];
		return ;
	}          
	
	int index1, index2, index3;
	index1 = MAX(indexes[0], MAX(indexes[1], indexes[2]));
	
	if(MIN(indexes[0],indexes[1]) > indexes[2])){
		index2 = MIN(indexes[0],indexes[1]);
	}else if(MAX(indexes[0],indexes[1]) < indexes [2]){
		index2 = MAX(indexes[0],indexes[1]);
	}else{
		index2 = indexes[2];
	}
	
	index3 = MIN(indexes[0], MIN(indexes[1], indexes[2]));
	
	
}
*/
- (NSBezierPath *)pathFragmentBetween:(int)index1 and:(int)index2
{
	NSPoint * points;
	
	int i, j;          
	int begin, end;
	begin = MIN(index1,index2);
	end = MAX(index1,index2);
	
	points = malloc(sizeof(NSPoint)* (end - begin +1 ) );
   	
	for( i = 0 , j = 0; i < _pointCount; i++ )
	{
		if(i <= end && i >= begin){
			points[j] = _points[i];
			j++;
		}
	}
	
	// generate path
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	DBDrawingView *view;
	BOOL canConvert; 

	NSPoint point;

	if ((end - begin +1 ) <= 0) {
		return nil;
	}

	view = [[[self layer] layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];

  	path = [[NSBezierPath bezierPath] retain];

	if(canConvert)
	{
		point = [view viewCoordinatesFromCanevasCoordinates:points[0]];
	}

	[path moveToPoint:point]; 

  	for( i = 1; i < (end - begin +1 ); i++ )
	{
		point = points[i];

		if(canConvert)
		{
			point = [view viewCoordinatesFromCanevasCoordinates:point];
		}

		[path lineToPoint:point];
  	}  
    
	return path;
}   

- (void)dealloc
{
	[_path release];
	_path = nil;
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

	CGContextEndTransparencyLayer([[NSGraphicsContext currentContext] graphicsPort]);

	[NSGraphicsContext restoreGraphicsState];

	if([[NSGraphicsContext currentContext] isKindOfClass:[NSBitmapGraphicsContext class]]){
		[_shadow reverseShadowOffsetHeight];
	}
	
	[[NSColor greenColor] set];
//	[[NSColor darkGrayColor] set];
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
		p = _points[i];
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
	
	if(!test && _pointCount == 2){
		return NSPointInRect(point, [[self path] bounds]);
	}
    if(!test){
		int i;
		NSPoint p;
		
		
		for( i = 0; i < _pointCount; i++ )
		{    
			p = _points[i];

			if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]))
			{
				return YES;
			}
	   	}
   		
		// no knob, so test the image draw point
		
		p = [_fill imageDrawPoint];
		p.x += _bounds.origin.x;
		p.y += _bounds.origin.y;

		if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]) && (([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) || [_fill fillMode] == DBGradientFillMode)){
			return YES;
		}
	}
     
  
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
	NSPoint point;
	
	if (_pointCount <= 0) {
		[_path release];
		_path = nil;
		return;
	}
	
	view = [[[self layer] layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	
	[_path release];
  	_path = [[NSBezierPath bezierPath] retain];

	point = _points[0];
	if(canConvert)
	{
		point = [view viewCoordinatesFromCanevasCoordinates:point];
	}

	[_path moveToPoint:point]; 
	
  	for( i = 1; i < _pointCount; i++ )
	{
		point = _points[i];
		
		if(canConvert)
		{
			point = [view viewCoordinatesFromCanevasCoordinates:point];
		}
		       
		[_path lineToPoint:point];
  	}  
	
	if(_lineIsClosed){
		[_path closePath];
	} 
	      
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
		p = _points[i];
		
		p.x -= rotationCenter.x;
		p.y -= rotationCenter.y;

		rotatedPoint.x = p.x*cos(deltaRot)-p.y*sin(deltaRot);
		rotatedPoint.y = p.x*sin(deltaRot)+p.y*cos(deltaRot);

		rotatedPoint.x += rotationCenter.x;
		rotatedPoint.y += rotationCenter.y;
		
		_points[i]=rotatedPoint;
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
		p = _points[i];
		
		p.x += deltaX;
		p.y += deltaY;
		
 		_points[i]=p;
  	}
   	
	[self updatePath];
	_bounds = [_path bounds];
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
		p = _points[i];

	   	p.x -= _bounds.origin.x;
		p.x = -p.x;
		p.x += _bounds.origin.x;

		_points[i]=p;		
	}

	[self updatePath];

}

- (void)flipHorizontalyWithNewKnob:(int)knob
{
	int i;
	NSPoint p;

	for( i = 0; i < _pointCount; i++ )
	{    
		p = _points[i];

	   	p.y -= _bounds.origin.y;
		p.y = -p.y;
		p.y += _bounds.origin.y;

		_points[i]=p;
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
 		p = _points[i];

    	p.x -= oldRect.origin.x;
    	p.y -= oldRect.origin.y;
        
		p.x *= xFactor;
		p.y *= yFactor;

    	p.x += newRect.origin.x;
    	p.y += newRect.origin.y;
		
  		_points[i]=p;
   	}

 	[self updatePath];
	[self updateBounds];

	[_fill resizeFillFromSize:oldRect.size toSize:newRect.size];
}

- (NSBezierPath *)path
{
	return _path;
}              

- (NSPoint *)points
{
	return _points;
}                  

- (int)pointCount
{
	return _pointCount;
}                      

- (void)setPoints:(NSPoint *)points count:(int)count
{
	_points = realloc(_points,count*sizeof(NSPoint));
	_pointCount = count;
	
	int i;

	for( i = 0; i < count; i++ )
	{
		_points[i] = points[i];
	}                          
}

- (void)setLineIsClosed:(BOOL)flag
{
	if(_lineIsClosed != flag){
		_lineIsClosed = flag;
		[self updateShape];
	}
}
#pragma mark Undo & Redo
- (void)setPoint:(NSPoint)p atIndex:(int)i
{
	[[[[_layer layerController] documentUndoManager] prepareWithInvocationTarget:self] setPoint:_points[i] atIndex:i];
	[[[_layer layerController] documentUndoManager] setActionName:NSLocalizedString(@"Edit", nil)];
	
	_points[i] = p;
	//NSLog(@"setpoint %@",NSStringFromPoint(_points[i]));
	                 
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
//	int addedPoints = 0;
	NSPoint * newPoints = malloc(sizeof(NSPoint));
	NSMutableIndexSet *idx;
  	int i,j;
    
	idx = [[NSMutableIndexSet alloc] init];
	for( i = [_selectedPoints indexGreaterThanOrEqualToIndex:0], j = 0; i != NSNotFound; i++, i = [_selectedPoints indexGreaterThanOrEqualToIndex:i])
	{
		if([_selectedPoints containsIndex:i+1]){
   			// add a point
			newPoints = realloc(newPoints, (j+1)*sizeof(NSPoint));
			newPoints[j].x = (_points[i].x + _points[i+1].x)/2.0;
			newPoints[j].y = (_points[i].y + _points[i+1].y)/2.0;
			// insert the new point
//			_points = insertPointAtIndex(newPoint,i+addedPoints+1, _points, _pointCount);

//			_pointCount++;
//			addedPoints++;
			[idx addIndex:i+j+1];
			j ++;
		}else{
			// don't add
		}
	}
	
	if(_lineIsClosed && [_selectedPoints containsIndex:0] && [_selectedPoints containsIndex:_pointCount-1]){
		newPoints[j].x = (_points[0].x + _points[_pointCount-1].x)/2.0;
		newPoints[j].y = (_points[0].y + _points[_pointCount-1].y)/2.0;
//		_pointCount++;
//		_points = realloc(_points, _pointCount*sizeof(NSPoint));
//		_points[_pointCount-1] = newPoint;
	}
	 
	[self insertPoints:newPoints atIndexes:idx];
	
	[self deselectAllPoints];
	
	[self updatePath];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[_layer updateRenderInView:nil];
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
}

/*- (void)delete:(id)sender
{
	// delete selected points
	NSPoint *newPoints;
	int i, j;
	
	newPoints = malloc(sizeof(NSPoint)*(_pointCount-[_selectedPoints count]));
   	
	for( i = 0, j = 0; i < _pointCount; i++ )
	{
		if(![_selectedPoints containsIndex:i]){
			newPoints[j] = _points[i];
			j++;
		}
	}
	
	free(_points);
	_points = newPoints;
	_pointCount = _pointCount-[_selectedPoints count];
	
	[self deselectAllPoints];

	[self updatePath];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	[_layer updateRenderInView:nil];
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
}  */

- (void)delete:(id)sender
{
	[self removePointsAtIndexes:_selectedPoints];
}

- (NSPoint)nearestPointOfPathToPoint:(NSPoint)point segment:(int *)seg
{
	NSPoint nearest;
	float nearestDist,dist, dX, dY;
	int index = -1;
	NSPoint p, a, b;
	float slope, k;
	
	nearestDist = 400;
	
	int i;

	for( i = 0; i < _pointCount-1; i++ )
	{   
		a = _points[i];
		b = _points[i+1];
		
		dX = a.x - b.x;
		dY = a.y - b.y;
		
		slope = dY/dX;
		k = a.y - slope*a.x;
		
		p.x = (point.x*dX*dX + point.y*dX*dY - dY*(a.x*b.y - a.y*b.x)) / ( (dX*dX)+(dY*dY) );
		
		if(a.x != b.x){
			p.y = slope*p.x + k;
		}else{
			p.y = (dX*(a.x*b.y - a.y*b.x) + point.y*dY*dY + point.x*dX*dY)/ ((dX*dX)+(dY*dY));
		}
		
		
		dX = point.x - p.x; dY = point.y - p.y;
		dist = dX*dX + dY*dY;
		
		if(nearestDist > dist){
			nearest = p;
			nearestDist = dist;
			index = i;
		}
	}
	
	if(_lineIsClosed){
		a = _points[_pointCount-1];
		b = _points[0];
		
		dX = a.x - b.x;
		dY = a.y - b.y;
		
		slope = dY/dX;
		k = a.y - slope*a.x;
		
		p.x = (point.x*dX*dX + point.y*dX*dY - dY*(a.x*b.y - a.y*b.x)) / ( (dX*dX)+(dY*dY) );

		if(a.x != b.x){
			p.y = slope*p.x + k;
		}else{
			p.y = (dX*(a.x*b.y - a.y*b.x) + point.y*dY*dY + point.x*dX*dY)/ ((dX*dX)+(dY*dY));
		}
		
		
		dX = point.x - p.x; dY = point.y - p.y;
		dist = dX*dX + dY*dY;
		
		if(nearestDist > dist){
			nearest = p;
			nearestDist = dist;
			index = _pointCount-1;
		}	
	}
	
	*seg = index;
	return nearest;
		
}

- (NSPoint *)pointsForIndexes:(NSIndexSet *)indexes
{
	int count = [indexes count];
	NSPoint *points = malloc(count*sizeof(NSPoint)); 
//	int idx = malloc(count*sizeof(int));
	
//	[indexes getIndexes:idx maxCount:count inIndexRange:nil];
	
	int i,j;
	
	for( i = 0, j = 0; i < _pointCount; i++ )
	{
		if([indexes containsIndex:i]){
			points[j] = _points[i];
			j++;
		}
	}
	
	return points;
}

- (void)removePointsAtIndexes:(NSIndexSet *)indexes
{
	DBUndoManager *undo = [[_layer layerController] documentUndoManager];
	NSPoint *points = [self pointsForIndexes:indexes];
	NSPoint *newPoints;
	int i,j;
	
    [[undo prepareWithInvocationTarget:self] insertPoints:points atIndexes:indexes];
	if(![undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Delete Point", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Insert Point", nil)];	
	}
	
//	_points = removePointAtIndex(index, _points, _pointCount);
//	_pointCount--; 
	
	
	newPoints = malloc(sizeof(NSPoint)*(_pointCount-[indexes count]));
   	
	for( i = 0, j = 0; i < _pointCount; i++ )
	{
		if(![indexes containsIndex:i]){
			newPoints[j] = _points[i];
			j++;
		}
	}
	
	free(_points);
	_points = newPoints;
	_pointCount = _pointCount-[indexes count];
	
	[self updatePath];
	[self updateBounds];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:_path];
	[_stroke updateStrokeForPath:_path]; 

	
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];	
}   

- (void)insertPoints:(NSPoint *)points atIndexes:(NSIndexSet *)indexes
{   
	// indexes represents the position of the points indexes in the new array
	DBUndoManager *undo = [[_layer layerController] documentUndoManager];
	[[undo prepareWithInvocationTarget:self] removePointsAtIndexes:indexes];
	if(![undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Insert Point", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Delete Point", nil)];	
	}
	
	NSPoint *newPoints = malloc(sizeof(NSPoint)*_pointCount+[indexes count]);
	
	int i,j,k;

	for( i = 0, j = 0,k = 0; i < _pointCount; j++ )
	{
		if([indexes containsIndex:j]){
			newPoints[j] = points[k];
			k++;
		}else{
			newPoints[j] = _points[i];
			i++;
		}
	}
	
	for(;k !=NSNotFound; k = [indexes indexGreaterThanIndex:k], j++)
	{                                                              
		newPoints[j]= points[k];
	}                                                              
	
	_pointCount += [indexes count];
	free(_points);
	_points = newPoints;
	
	
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
		_points[i] = [at transformPoint:_points[i]];
	}
	
	[self updateShape];
}

@end
