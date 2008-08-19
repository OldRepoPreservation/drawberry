//
//  DBRectangle.m
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBRectangle.h"
#import "DBShape.h"  

#import "DBPolyline.h"
#import "DBBezierCurve.h"

#import "NSBezierPath+Extensions.h"

@class NSBitmapGraphicsContext;

static double distanceBetween(NSPoint a, NSPoint b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  return sqrt (dx * dx + dy * dy);
}

@implementation DBRectangle

- (id)initWithRect:(NSRect)rect
{
	self = [super init];
	
	_point1 = rect.origin;
	_point2 = rect.origin;
	_point3 = rect.origin;
	_point4 = rect.origin;
	       
	_point2.x += rect.size.width;     
	_point4.y += rect.size.height;     
	_point3.x += rect.size.width;     
	_point3.y += rect.size.height;
	
	_radiusKnob = _point2;
	
	[self updatePath];
	[self updateBounds];
	[self strokeUpdated];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	            	
	_point1 = NSPointFromString([decoder decodeObjectForKey:@"First Point"]);
	_point2 = NSPointFromString([decoder decodeObjectForKey:@"Second Point"]);
	_point3 = NSPointFromString([decoder decodeObjectForKey:@"Third Point"]);
	_point4 = NSPointFromString([decoder decodeObjectForKey:@"Fourth Point"]);
	_radiusKnob = NSPointFromString([decoder decodeObjectForKey:@"Knob Point"]);

	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:NSStringFromPoint(_point1) forKey:@"First Point"];
	[encoder encodeObject:NSStringFromPoint(_point2) forKey:@"Second Point"];
	[encoder encodeObject:NSStringFromPoint(_point3) forKey:@"Third Point"];
	[encoder encodeObject:NSStringFromPoint(_point4) forKey:@"Fourth Point"];
	[encoder encodeObject:NSStringFromPoint(_radiusKnob) forKey:@"Knob Point"];
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
	_radiusKnob = point;
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

		_radiusKnob = _point2;
		
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
	NSPoint point, center;
	BOOL canConvert;     
	NSAutoreleasePool *pool;
	float tX, tY;
	float angle, slope, k;
	
	angle =  (M_PI/180)*_rotation;
	slope = tan(angle - M_PI/2.0);
	k = _point2.y - slope*_point2.x;
	
	tX = MIN(MIN(_point1.x, _point2.x), MIN(_point3.x, _point4.x)); // + distanceBetween(_point2, _point1)/2.0;
	tY = MIN(MIN(_point1.y, _point2.y), MIN(_point3.y, _point4.y)); // + distanceBetween(_point2, _point3)/2.0;
	center = _boundsCenter;

	canConvert = [view isKindOfClass:[DBDrawingView class]];
   
	point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
  
	if(canConvert){
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
	
	if(!DBPointIsOnKnobAtPointZoom(point,_radiusKnob,[view zoom])){ 
		[view setNeedsDisplay:YES];
	
		// no knob is selected
		// try the fill image draw point
		return [self changeFillImageDrawPointWithEvent:theEvent inView:view];
	}
		
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
        
		[view moveMouseRulerMarkerWithEvent:theEvent];

		if(canConvert){
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
		  	
		if(_rotation == (0.0) || angle == (M_PI)){
			_radiusKnob.x = _point2.x;
			_radiusKnob.y = point.y;
		}else if((angle > 0.0 && angle < M_PI/6.0) 
			 || (angle > (5.0*M_PI/6.0) && (angle < (7.0*M_PI/6.0)))
			 || (angle > (11.0*M_PI/6.0) && (angle < (12.0*M_PI/6.0))) ) {
				_radiusKnob.y = point.y;
				_radiusKnob.x = (_radiusKnob.y - k)/slope;
		}else{
			_radiusKnob.x = point.x;
			_radiusKnob.y = slope*_radiusKnob.x + k;
		}
		
		if((_point2.x < _radiusKnob.x && _point3.x < _radiusKnob.x ) || (_point2.x > _radiusKnob.x && _point3.x > _radiusKnob.x )){
			_radiusKnob = _point2;
		}else if((_point2.y < _radiusKnob.y && _point3.y < _radiusKnob.y ) || (_point2.y > _radiusKnob.y && _point3.y > _radiusKnob.y )){
			_radiusKnob = _point2;
		}
		else if(distanceBetween(_point2, _radiusKnob) > MIN(distanceBetween(_point1,_point2)/2.0, distanceBetween(_point1,_point3)/2.0) ){
			if(_rotation == (0.0) || angle == (M_PI)){
				_radiusKnob.x = _point2.x;
				_radiusKnob.y = _point2.y + MIN(distanceBetween(_point1,_point2)/2.0, distanceBetween(_point1,_point3)/2.0);
			}else{
				_radiusKnob.x = (_point2.x + _point3.x)/2.0;
				_radiusKnob.y = slope*_radiusKnob.x + k;
			}
		}                          
		
		[self updatePath];
		[_fill updateFillForPath:_path];
        [_stroke updateStrokeForPath:_path];  

		[view setNeedsDisplay:YES];

		[pool release];
		
		if([theEvent type] == NSLeftMouseUp)
		{
			break;
		}
	}
	
	[_fill updateFillForPath:_path];
	[_stroke updateStrokeForPath:_path]; 
	[_layer updateRenderInView:nil];
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	 	
	return YES;
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
	_radiusKnob.x += deltaX;
	_radiusKnob.y += deltaY;
	
	[self updatePath];
	[self updateBounds];
}

- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags
{
	int newKnob = 0;
	newKnob = [super resizeByMovingKnob:knob fromPoint:fromPoint toPoint:point inView:view modifierFlags:flags];  
	
	[self putPathInRect:_bounds];              
	
	[_stroke updateStrokeForPath:_path]; 
	[_fill updateFillForPath:_path];
		
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
	_radiusKnob=rotatePoint(_radiusKnob,rotationCenter,deltaRot);

	[self updatePath];
	[self updateBounds];
}

- (void)drawInView:(DBDrawingView *)view rect:(NSRect)rect
{         
	[[NSColor redColor] set];
	//[NSBezierPath fillRect:rect];
	
	if(!NSIsEmptyRect(rect) && !NSIntersectsRect(rect, _bounds) && !NSIsEmptyRect(_bounds)){
		return;
	}
   // NSLog(@"drawing rect");
   	
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
	NSView *view = [[[self layer] layerController] drawingView];
	NSPoint p = _radiusKnob;
   
 	if([view isKindOfClass:[DBDrawingView class]]){
		p = [(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_radiusKnob];
	}
	
	[[DBShape grayKnob] drawAtPoint:NSMakePoint(p.x-5.0,p.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	
	if(([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) ){
		p = [_fill imageDrawPoint];
		p.x *= [self zoom];
		p.x += _bounds.origin.x;
		p.y *= [self zoom];
		p.y += _bounds.origin.y;
		
		[[DBShape greenKnob] drawAtPoint:NSMakePoint(p.x-5.0,p.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];		
	}
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

	_point1 = resizePoint(_point1, oldRect.origin, newRect.origin, xFactor, yFactor);
	_point2 = resizePoint(_point2, oldRect.origin, newRect.origin, xFactor, yFactor);
	_point3 = resizePoint(_point3, oldRect.origin, newRect.origin, xFactor, yFactor);
	_point4 = resizePoint(_point4, oldRect.origin, newRect.origin, xFactor, yFactor);
	_radiusKnob = resizePoint(_radiusKnob, oldRect.origin, newRect.origin, xFactor, yFactor);
	
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
//	float minX, minY;
	NSAffineTransform *transform;
	float zoom;
	DBDrawingView *view;
	BOOL canConvert; 
	
	view = [[_layer layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];

	if(canConvert)
	{
		zoom = [view zoom];
	}else{
		zoom = 1.0f;
	}
	rect.size = NSMakeSize(zoom*distanceBetween(_point2, _point1), zoom*distanceBetween(_point2, _point3));
 // make the rectangle center be on (0,0)

	rect.origin = NSMakePoint(-rect.size.width/2.0, -rect.size.height/2.0);
	[_path release];
// 	_path = [[NSBezierPath bezierPath] retain];  
//	[_path appendBezierPathWithRect:rect];
  
  	_path = [NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:distanceBetween(_point2, _radiusKnob)*zoom];
	[_path retain];
	
	transform = [[NSAffineTransform alloc] init];
	[transform rotateByDegrees:_rotation];
	
	[_path transformUsingAffineTransform:transform];
	
	rect = [_path bounds];
	
	[transform release];
	transform = [[NSAffineTransform alloc] init];
	
	// upper left corner on (0,0) and then translate to correct place
	translationVec.x = MIN(MIN(_point1.x, _point2.x), MIN(_point3.x, _point4.x));
	translationVec.y = MIN(MIN(_point1.y, _point2.y), MIN(_point3.y, _point4.y));
	
	if(canConvert){	
		translationVec = [view viewCoordinatesFromCanevasCoordinates:translationVec];
	}
		
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
	
	test = [_path containsPoint:point];
	 
	if(!test){
		DBDrawingView *view = [[_layer layerController] drawingView];
		
		if(view){
			test = DBPointIsOnKnobAtPointZoom([view canevasCoordinatesFromViewCoordinates:point],_radiusKnob,[view zoom]);
		}else{
			test = DBPointIsOnKnobAtPointZoom(point,_radiusKnob,1.0);
		}
	}
    if(!test){
		NSPoint p;
		
		point = [[[[self layer] layerController] drawingView] canevasCoordinatesFromViewCoordinates:point];
		// no knob, so test the image draw point
		
		p = [_fill imageDrawPoint];
		p.x += _bounds.origin.x;
		p.y += _bounds.origin.y;

		if(DBPointIsOnKnobAtPointZoom(point,p,[[[_layer layerController] drawingView] zoom]) && (([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) || [_fill fillMode] == DBGradientFillMode)){
			return YES;
		}
	}
     
//	NSLog(@"test : %@, %@", NSStringFromPoint(point), NSStringFromRect(_bounds));

		// no knob, so test the image draw point
		
	NSPoint p = [_fill imageDrawPoint];
	p.x += _bounds.origin.x;
	p.y += _bounds.origin.y;

//	if(DBPointIsOnKnobAtPoint(point,p) && (([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) || [_fill fillMode] == DBGradientFillMode)){
//		return YES;
//	}
 
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
	if(distanceBetween(_point2, _radiusKnob) == 0){
		shape = [[DBPolyline alloc] init];
		NSPoint points[4];
		
		points[0] = _point1;
		points[1] = _point2;
		points[2] = _point3;
		points[3] = _point4;
		
		[shape setPoints:points count:4];
		[shape setLineIsClosed:YES];
	}else{
		NSAffineTransform *af;

		af = [[[[self layer] layerController] drawingView] appliedTransformation];
		[af invert];
		shape = [[DBBezierCurve alloc] initWithPath:[af transformBezierPath:_path]];		
	} 
	
	
	return shape;
}
@end
