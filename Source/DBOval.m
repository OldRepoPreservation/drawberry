//
//  DBRectangle.m
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBOval.h"
#import "DBShape.h"

#import "DBBezierCurve.h"


@class NSBitmapGraphicsContext;

static double distanceBetween(NSPoint a, NSPoint b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  return sqrt (dx * dx + dy * dy);
}

@implementation DBOval
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	            	
	_point1 = NSPointFromString([decoder decodeObjectForKey:@"First Point"]);
	_point2 = NSPointFromString([decoder decodeObjectForKey:@"Second Point"]);
	_point3 = NSPointFromString([decoder decodeObjectForKey:@"Third Point"]);
	_point4 = NSPointFromString([decoder decodeObjectForKey:@"Fourth Point"]);

	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:NSStringFromPoint(_point1) forKey:@"First Point"];
	[encoder encodeObject:NSStringFromPoint(_point2) forKey:@"Second Point"];
	[encoder encodeObject:NSStringFromPoint(_point3) forKey:@"Third Point"];
	[encoder encodeObject:NSStringFromPoint(_point4) forKey:@"Fourth Point"];
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint previousLoc, vec;
	NSAutoreleasePool *pool;
    float dX, dY;

	if([view isKindOfClass:[DBDrawingView class]])
	{		
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	
	_point1 = point;
	_point2 = point;
	_point3 = point;
	_point4 = point;

	previousLoc = point;
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];

		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
		[view moveMouseRulerMarkerWithEvent:theEvent];
    
		point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
				
		if([view isKindOfClass:[DBDrawingView class]])
		{
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}

        dX = point.x - _point1.x;
		dY = point.y - _point1.y;
		vec = NSMakePoint((point.x-previousLoc.x),(point.y - previousLoc.y));
		
		if([theEvent modifierFlags] & NSShiftKeyMask){
			if(fabs(dX) < fabs(dY)){
				point.y = _point1.y + dX;
			}else{
				point.x = _point1.x + dY;
			}
		}
		
//		vec = NSZeroPoint;
		
		_point3 = point;
		_point2.x = _point3.x;
		_point4.y = _point3.y;
   	
		[self updatePath];
		[self updateBounds];
		[view setNeedsDisplay:YES];
		
//		previousLoc = point;
		if([theEvent type] == NSLeftMouseUp){
			break;
		}
	}
	
	return YES; 
}

- (BOOL)editWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	[view setNeedsDisplay:YES];
	return [self changeFillImageDrawPointWithEvent:theEvent inView:view];
}
- (void)moveByX:(float)deltaX byY:(float)deltaY
{
	[super moveByX:deltaX byY:deltaY];
	   	
	_point1.x += deltaX;
	_point1.y += deltaY;
	_point2.x += deltaX;
	_point2.y += deltaY;
	_point3.x += deltaX;
	_point3.y += deltaY;
	_point4.x += deltaX;
	_point4.y += deltaY;
	
	[self updatePath];
	_bounds = [_path bounds];
	_boundsCenter.x += deltaX;
	_boundsCenter.y += deltaY;
}

- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags
{
	int newKnob = 0;
	newKnob = [super resizeByMovingKnob:knob fromPoint:fromPoint toPoint:point inView:view modifierFlags:flags];  
	
	[self putPathInRect:_bounds];
	
	[_fill updateFillForPath:_path];
	[_stroke updateStrokeForPath:_path]; 
		
	return newKnob;
}

- (void)rotate:(float)deltaRot
{
	NSPoint rotationCenter = [[[[self layer] layerController] drawingView] canevasCoordinatesFromViewCoordinates:_boundsCenter];
	deltaRot = (M_PI/180)*deltaRot;
	               
	_point1=rotatePoint(_point1,rotationCenter,deltaRot);
	_point2=rotatePoint(_point2,rotationCenter,deltaRot);
	_point3=rotatePoint(_point3,rotationCenter,deltaRot);
	_point4=rotatePoint(_point4,rotationCenter,deltaRot);

	[self updatePath];
	[self updateBounds];
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
	[[self fill] fillPath:_path];
	
	[[self stroke] strokePath:_path];
	[NSGraphicsContext restoreGraphicsState];

   	if([[NSGraphicsContext currentContext] isKindOfClass:[NSBitmapGraphicsContext class]]){
		[_shadow reverseShadowOffsetHeight];
	}
}

- (void)displayEditingKnobs
{
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

- (void)putPathInRect:(NSRect)newRect
{
	if(newRect.size.width == 0 || newRect.size.height == 0){
		return;
	} 
	
	NSRect oldRect;
	
	oldRect = [_path bounds];
	oldRect.origin = [[[[self layer] layerController] drawingView] canevasCoordinatesFromViewCoordinates:oldRect.origin];
	
	float xFactor, yFactor;
	
	xFactor = newRect.size.width / oldRect.size.width; 
	yFactor = newRect.size.height / oldRect.size.height;
    
	newRect.origin = [[[[self layer] layerController] drawingView] canevasCoordinatesFromViewCoordinates:newRect.origin];

	_point1 = resizePoint(_point1,oldRect.origin, newRect.origin, xFactor, yFactor);
	_point2 = resizePoint(_point2,oldRect.origin, newRect.origin, xFactor, yFactor);
	_point3 = resizePoint(_point3,oldRect.origin, newRect.origin, xFactor, yFactor);
	_point4 = resizePoint(_point4,oldRect.origin, newRect.origin, xFactor, yFactor);
	
 	[self updatePath];
	[self updateBounds];

	[_fill resizeFillFromSize:oldRect.size toSize:newRect.size];
}

- (NSBezierPath *)path
{
	return _path;
}

- (void)updateShape
{
	[super updateShape];
	[self updatePath];
}

- (void)updatePath
{
	NSRect rect;
	NSPoint translationVec;
	NSAffineTransform *transform;
	DBDrawingView *view;
	BOOL canConvert; 
	float zoom;
	
	view = [[_layer layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	
	if(canConvert)
	{
		zoom = [view zoom];
	}else{
		zoom = 1.0f;
	}
	
//	rect.size = NSMakeSize(distanceBetween(_point2, _point1), distanceBetween(_point2, _point3));
	rect.size = NSMakeSize(zoom*distanceBetween(_point2, _point1), zoom*distanceBetween(_point2, _point3));
 // make the rectangle center be on (0,0)

	rect.origin = NSZeroPoint;
	rect.origin = NSMakePoint(-rect.size.width/2.0, -rect.size.height/2.0);

	[_path release];
  	_path = [[NSBezierPath bezierPath] retain];
	
	[_path appendBezierPathWithOvalInRect:rect];
	
	transform = [[NSAffineTransform alloc] init];
	[transform rotateByDegrees:_rotation];
	
	[_path transformUsingAffineTransform:transform];
	
	rect = [_path bounds];
	
	[transform release];
	transform = [[NSAffineTransform alloc] init];
	
	// upper left corner on (0,0) and then translate to correct place
	translationVec.x = MIN(MIN(_point1.x, _point2.x), MIN(_point3.x, _point4.x));
	translationVec.y = MIN(MIN(_point1.y, _point2.y), MIN(_point3.y, _point4.y));
		
	translationVec = [view viewCoordinatesFromCanevasCoordinates:translationVec];
		
	[transform translateXBy:(-rect.origin.x+translationVec.x) yBy:(-rect.origin.y+translationVec.y)];
	[_path transformUsingAffineTransform:transform];
	
	[transform release];
}   

- (void)updateBounds
{
	_bounds = [_path bounds]; 
	_boundsSize= _bounds.size;
	_boundsCenter = _bounds.origin;
	_boundsCenter.x += _boundsSize.width/2;
	_boundsCenter.y += _boundsSize.height/2;
}   

- (void)strokeUpdated
{
	[_fill updateFillForPath:_path];
	[_stroke updateStrokeForPath:_path]; 
	[super strokeUpdated];
}

- (BOOL)hitTest:(NSPoint)point
{
	BOOL test;
	NSPoint p;
	DBDrawingView *view = [[_layer layerController] drawingView];
	test = [_path containsPoint:point];
	
    if(!test){
		
		point = [[[[self layer] layerController] drawingView] canevasCoordinatesFromViewCoordinates:point];
		// no knob, so test the image draw point
		
		p = [_fill imageDrawPoint];
		p.x += _bounds.origin.x;
		p.y += _bounds.origin.y;

		if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]) && (([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) || [_fill fillMode] == DBGradientFillMode)){
			return YES;
		}
	}
     
//	NSLog(@"test : %@, %@", NSStringFromPoint(point), NSStringFromRect(_bounds));
  	
		// no knob, so test the image draw point
		
	p = [_fill imageDrawPoint];
	p.x += _bounds.origin.x;
	p.y += _bounds.origin.y;

	if(DBPointIsOnKnobAtPointZoom(point,p,[view zoom]) && (([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) || [_fill fillMode] == DBGradientFillMode)){
		return YES;
	}

  	return test;
} 

- (BOOL)canEdit
{
	return YES;
}

#pragma mark Convert

- (DBShape *)convert
{
	DBShape *shape;
	NSAffineTransform *af;
	
	af = [[[[self layer] layerController] drawingView] appliedTransformation];
	[af invert];
	shape = [[DBBezierCurve alloc] initWithPath:[af transformBezierPath:_path]];		
	
	
	return shape;
}

@end
