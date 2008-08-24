//
//  DBShape.m
//  DrawBerry
//
//  Created by Raphael Bost on 10/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBShape.h"
#import "DBLayer.h"

static NSImage *__blueKnob = nil;
static NSImage *__grayKnob = nil;
static NSImage *__selectedGrayKnob = nil;
static NSImage *__smallGrayKnob = nil;
static NSImage *__whiteKnob = nil;
static NSImage *__orangeKnob = nil;
static NSImage *__greenKnob = nil;

@implementation DBShape

+ (NSImage *)blueKnob
{
	if(!__blueKnob)
	{
		__blueKnob = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
		
		[__blueKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(5,5) radius:4 startAngle:0 endAngle:360];

		[[NSColor selectedControlColor] set];
		[circle fill];
		[[NSColor alternateSelectedControlColor] set];
		[circle stroke];

		[__blueKnob unlockFocus];
	}
	return __blueKnob;
}

+ (NSImage *)grayKnob
{
	if(!__grayKnob)
	{
		__grayKnob = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
		
		[__grayKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(5,5) radius:4 startAngle:0 endAngle:360];
		
 		[[NSColor lightGrayColor] set];
   		[circle fill];
		[[NSColor grayColor] set];
		[circle stroke];
		
		[__grayKnob unlockFocus];
	}
	return __grayKnob;
}

+ (NSImage *)smallGrayKnob
{
//	if(!__smallGrayKnob)
//    {
		__smallGrayKnob = [[NSImage alloc] initWithSize:NSMakeSize(8,8)];
		
		[__smallGrayKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(4,4) radius:3 startAngle:0 endAngle:360];
		
 		[[NSColor lightGrayColor] set];
   		[circle fill];
		[[NSColor grayColor] set];
		[circle stroke];
		
		[__smallGrayKnob unlockFocus];
//	}
	return [__smallGrayKnob autorelease];
}

+ (NSImage *)whiteKnob
{
	if(!__whiteKnob)
	{
		__whiteKnob = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
		
		[__whiteKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(5,5) radius:4 startAngle:0 endAngle:360];
		[[NSColor whiteColor] set];
		[circle fill];
   		[[NSColor lightGrayColor] set];
		[circle stroke];
		[__whiteKnob unlockFocus];
	}
	return __whiteKnob;
}   

+ (NSImage *)orangeKnob
{
	if(!__orangeKnob)
	{
		__orangeKnob = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
		
		[__orangeKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(5,5) radius:4 startAngle:0 endAngle:360];

		[[NSColor yellowColor] set];
		[circle fill];
		[[NSColor orangeColor] set];
		[circle stroke];
		[__orangeKnob unlockFocus];
	}
	return __orangeKnob;
}   

+ (NSImage *)greenKnob
{
	if(!__greenKnob)
	{
		__greenKnob = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
		
		[__greenKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(5,5) radius:4 startAngle:0 endAngle:360];

		[[NSColor greenColor] set];
		[circle fill];
		[[NSColor colorWithCalibratedRed:0.0 green:0.6 blue:0.0 alpha:1.0] set];
		[circle stroke];
		[__greenKnob unlockFocus];
	}
	return __greenKnob;
}   

+ (NSImage *)selectedGrayKnob
{
	if(!__selectedGrayKnob)
	{
		__selectedGrayKnob = [[NSImage alloc] initWithSize:NSMakeSize(10,10)];
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor selectedControlColor] endingColor:[NSColor lightGrayColor]];
		
		[__selectedGrayKnob lockFocus];
		NSBezierPath *circle = [NSBezierPath bezierPath];
		[circle appendBezierPathWithArcWithCenter:NSMakePoint(5,5) radius:4 startAngle:0 endAngle:360];
		   	
		[gradient drawInBezierPath:circle relativeCenterPosition:NSZeroPoint];
		[gradient release];
		
		[[NSColor alternateSelectedControlColor] set];
		[circle stroke];
		
		[__selectedGrayKnob unlockFocus];
	}
	return __selectedGrayKnob;
}

+ (int)flipKnob:(int)knob horizontal:(BOOL)horizFlag {
    static BOOL initedFlips = NO;
    static int horizFlips[9];
    static int vertFlips[9];

    if (!initedFlips) {
        horizFlips[UpperLeftKnob] = UpperRightKnob;
        horizFlips[UpperMiddleKnob] = UpperMiddleKnob;
        horizFlips[UpperRightKnob] = UpperLeftKnob;
        horizFlips[MiddleLeftKnob] = MiddleRightKnob;
        horizFlips[MiddleRightKnob] = MiddleLeftKnob;
        horizFlips[LowerLeftKnob] = LowerRightKnob;
        horizFlips[LowerMiddleKnob] = LowerMiddleKnob;
        horizFlips[LowerRightKnob] = LowerLeftKnob;
        
        vertFlips[UpperLeftKnob] = LowerLeftKnob;
        vertFlips[UpperMiddleKnob] = LowerMiddleKnob;
        vertFlips[UpperRightKnob] = LowerRightKnob;
        vertFlips[MiddleLeftKnob] = MiddleLeftKnob;
        vertFlips[MiddleRightKnob] = MiddleRightKnob;
        vertFlips[LowerLeftKnob] = UpperLeftKnob;
        vertFlips[LowerMiddleKnob] = UpperMiddleKnob;
        vertFlips[LowerRightKnob] = UpperRightKnob;
        initedFlips = YES;
    }
    if (horizFlag) {
        return horizFlips[knob];
    } else {
        return vertFlips[knob];
    }
}

+ (NSRect)enclosingRectForShapes:(NSArray *)shapes                                     
{
	NSRect rect = NSZeroRect;
	NSEnumerator *e = [shapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		rect = NSUnionRect(rect,[shape bounds]);
	}
	
	return rect;
}

#pragma mark Initialize & co
- (id)init
{
	self = [super init];
	
	_stroke = [[DBStroke alloc] initWithShape:self];            
	_fill = [[DBFill alloc] initWithShape:self];            
	_shadow = [[DBShadow alloc] initWithShape:self];
	
	return self;
}

- (void)dealloc
{
	[_stroke dealloc];
	[_fill release];
	[_shadow release]; 
	
	[super dealloc];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	            
	[self setRotation:[decoder decodeFloatForKey:@"Rotation"]];
	
	_fill = [[decoder decodeObjectForKey:@"Fill"] retain];
	[_fill setShape:self];
	_stroke = [[decoder decodeObjectForKey:@"Stroke"] retain];
	[_stroke setShape:self];
	_shadow = [[decoder decodeObjectForKey:@"Shadow"] retain];
	[_shadow setShape:self];
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeFloat:_rotation forKey:@"Rotation"];
	[encoder encodeObject:_fill forKey:@"Fill"];
	[encoder encodeObject:_stroke forKey:@"Stroke"];
	[encoder encodeObject:_shadow forKey:@"Shadow"];
}

#pragma mark Displaying

- (void)drawInView:(NSView *)view rect:(NSRect)rect
{
	
}

- (void)displayEditingKnobs
{
	
}

- (void)displaySelectionKnobs
{
	NSPoint upLeft, bottomLeft, bottomRight, upRight;
	NSPoint midLeft, midRight, midUp, midBottom;
    
	upLeft = NSMakePoint(NSMinX(_bounds),NSMinY(_bounds));
	bottomLeft = NSMakePoint(NSMaxX(_bounds),NSMinY(_bounds));
	bottomRight = NSMakePoint(NSMaxX(_bounds),NSMaxY(_bounds));
	upRight = NSMakePoint(NSMinX(_bounds),NSMaxY(_bounds));
	
	midLeft = NSMakePoint(NSMinX(_bounds),NSMinY(_bounds)+NSHeight(_bounds)/2);
	midRight = NSMakePoint(NSMaxX(_bounds),NSMinY(_bounds)+NSHeight(_bounds)/2);
	midUp = NSMakePoint(NSMinX(_bounds)+NSWidth(_bounds)/2,NSMinY(_bounds));
	midBottom = NSMakePoint(NSMinX(_bounds)+NSWidth(_bounds)/2,NSMaxY(_bounds));
	
	// draw knobs
	
	BOOL canConvert;     
	DBDrawingView *view;
	
	view = [[[self layer] layerController] drawingView];
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	
/*	point1 = [view viewCoordinatesFromCanevasCoordinates:point1];
	point2 = [view viewCoordinatesFromCanevasCoordinates:point2];
	point3 = [view viewCoordinatesFromCanevasCoordinates:point3];
	point4 = [view viewCoordinatesFromCanevasCoordinates:point4];
*/	
	if([[NSApp currentEvent] modifierFlags] & NSControlKeyMask){
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(upLeft.x-5.0,upLeft.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(bottomLeft.x-5.0,bottomLeft.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(bottomRight.x-5.0,bottomRight.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(upRight.x-5.0,upRight.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(midLeft.x-5.0,midLeft.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(midRight.x-5.0,midRight.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(midUp.x-5.0,midUp.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape orangeKnob] drawAtPoint:NSMakePoint(midBottom.x-5.0,midBottom.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
	}else{
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(upLeft.x-5.0,upLeft.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(bottomLeft.x-5.0,bottomLeft.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(bottomRight.x-5.0,bottomRight.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(upRight.x-5.0,upRight.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	

		[[DBShape blueKnob] drawAtPoint:NSMakePoint(midLeft.x-5.0,midLeft.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(midRight.x-5.0,midRight.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(midUp.x-5.0,midUp.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
		[[DBShape blueKnob] drawAtPoint:NSMakePoint(midBottom.x-5.0,midBottom.y-5.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	
	}
}

- (void)drawBounds
{
	float dash[2] = {5.0,5.0};                                   
   	[[NSColor blackColor] set];
	//[[NSColor darkGrayColor] set];

	NSBezierPath *path = [NSBezierPath bezierPathWithRect:_bounds];
	[path setLineWidth:0.5];                            
	[path setLineDash:dash count:2 phase:0.0];
	[path stroke];
}    

#pragma mark Accessors
- (DBLayer *)layer
{
	return _layer;
}

- (void)setLayer:(DBLayer *)newLayer
{
	if(_layer != newLayer){

		[self retain]; // retain us because otherwise, we might be freed by the next line

		if([[_layer shapes] containsObject:self]){
			[_layer removeShape:self];
		}
		_layer = newLayer;
		
		if(![[_layer shapes] containsObject:self] && [_layer tempShape] != self){
			[_layer addShape:self];
		}
  		[self release]; // it's done, let's release us
	}
}

- (BOOL)isEditing
{
	return _isEditing;
}

- (void)setIsEditing:(BOOL)newIsEditing
{
	_isEditing = newIsEditing;
}

- (float)rotation
{
	return _rotation;
}

- (void)setRotation:(float)newRotation
{
	while(1){
		if(newRotation >= 360)
		{
			newRotation -= 360; 
		}else{
			break;
		}
	}

	while(1){
		if(newRotation < 0)
		{
			newRotation += 360; 
		}else{
			break;
		}
	}

	if(newRotation != _rotation){
//		[[[[self layer] layerController] drawingView] setNeedsDisplay:YES]; 
		float delta;
		delta = newRotation - _rotation;
		[self rotate:delta];
		_rotation = newRotation;
		
		[_stroke updateStrokeForPath:nil];
		[[self layer] updateRenderInView:nil];
  		[[[self layer] layerController] updateDependentLayers:[self layer]];

		[[[[self layer] layerController] drawingView] setNeedsDisplay:YES]; 
	}
}

- (NSPoint)rotationCenter
{
	return _boundsCenter;
}

- (void)rotate:(float)deltaRot
{
	
}

- (void)moveByX:(float)deltaX byY:(float)deltaY
{
	
	NSRect translatedRect, unionRect;
	translatedRect = _bounds;
	translatedRect.origin.x += deltaX;
	translatedRect.origin.y += deltaY;
	unionRect = NSUnionRect(_bounds, translatedRect);
	unionRect.origin.x -= 5.0;
	unionRect.origin.y -= 5.0;
	unionRect.size.height += 10.0;
	unionRect.size.width += 11.0;
	
	[[[[self layer] layerController] drawingView] setNeedsDisplayInRect:unionRect]; 
	
//	NSLog(@"move");
}   

- (void)moveCorner:(int)corner toPoint:(NSPoint)point
{
	NSPoint ulCorner;
	
	ulCorner = [self bounds].origin;
	
	switch(corner)
	{
		case 1 : ; break; // upper left
		case 2 : point.y -= [self bounds].size.height ; break; // lower left
		case 3 : point.x -= [self bounds].size.width ; break;  // upper right
		case 4 : point.x -= [self bounds].size.width; point.y -= [self bounds].size.height ; break;
	}
	
	[self moveByX:point.x-ulCorner.x byY:point.y-ulCorner.y];
}   

- (NSPoint)translationToCenterInRect:(NSRect)rect
{
	NSPoint corner,center;
	NSSize size;
	
	corner = [self bounds].origin;
	
	center = rect.origin;
	center.x += rect.size.width/2.0;
	center.y += rect.size.height/2.0;
	
	size = [self bounds].size;
	corner = center;
	corner.x -= size.width/2.0;
	corner.y -= size.height/2.0;
	
	return NSMakePoint([self bounds].origin.x - corner.x,[self bounds].origin.y - corner.y);
}

- (DBStroke *)stroke
{
	return _stroke;
}

- (void)setStroke:(DBStroke *)newStroke
{
	[newStroke retain];
	[_stroke release];
	_stroke = newStroke;
	[_stroke setShape:self];
}    

- (DBFill *)fill
{
	return _fill;
}

- (void)setFill:(DBFill *)newFill
{
	[newFill retain];
	[_fill release];
	_fill = newFill;
	[_fill setShape:self];
}    

- (NSBezierPath *)path
{
	return nil;
}              

- (NSRect)bounds
{
	return _bounds;
}                  

- (float)zoom
{
	return [[[[self layer] layerController] drawingView] zoom];
}

#pragma mark Edition and Creation
- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	return NO;
}

- (BOOL)editWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	return NO;
}

- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags 
{
	if(flags & NSAlternateKeyMask){
		float dX, dY, ratio;
		dX = point.x - fromPoint.x;
		dY = point.y - fromPoint.y;
		ratio = _bounds.size.width/ _bounds.size.height;

		if((fabs(dX) < fabs(dY) || (knob == MiddleLeftKnob) || (knob == MiddleRightKnob) ) && (knob != LowerMiddleKnob) && (knob != UpperMiddleKnob) ){
			dY = (_bounds.size.width+dX)/ratio - _bounds.size.height;
		}else{
			dX = ratio*(_bounds.size.height+dY) - _bounds.size.width;
   		}
		point.x = fromPoint.x + dX;
		point.y = fromPoint.y + dY;
				
		if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob) || (knob == UpperMiddleKnob)) {
	        // Adjust left edge
			_bounds.size.width -= dX;  
	    	_bounds.origin.x += dX;
	    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob) || (knob == LowerMiddleKnob)) {
			// Adjust right edge
			_bounds.size.width += dX;  
	    }
	    
		if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob) || (knob == MiddleLeftKnob)) {
	        // Adjust top edge
			_bounds.size.height -= dY;
	    	_bounds.origin.y += dY;
	    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob) || (knob == MiddleRightKnob)) {
	        // Adjust bottom edge
			_bounds.size.height += dY;
	    }

		if (_bounds.size.width < 0.0) {
			knob = [DBShape flipKnob:knob horizontal:YES];
	        _bounds.size.width = -_bounds.size.width;
	        _bounds.origin.x -= _bounds.size.width;

	     	[self flipVerticallyWithNewKnob:knob];

	    }
	    if (_bounds.size.height < 0.0) { 
	        knob = [DBShape flipKnob:knob horizontal:NO];
	        _bounds.size.height = -_bounds.size.height;
	        _bounds.origin.y -= _bounds.size.height;
	     	[self flipHorizontalyWithNewKnob:knob];
	    } 
	    
   	}
  	else
	{
		if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob)) {
	        // Adjust left edge
			_bounds.size.width = NSMaxX(_bounds) - point.x;
	    	_bounds.origin.x = point.x;
	    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob)) {
			// Adjust right edge
			_bounds.size.width = point.x - _bounds.origin.x;  
	    }
	    if (_bounds.size.width < 0.0) {
			knob = [DBShape flipKnob:knob horizontal:YES];
	        _bounds.size.width = -_bounds.size.width;
	        _bounds.origin.x -= _bounds.size.width;

	     	[self flipVerticallyWithNewKnob:knob];

	    }

	    if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob)) {
	        // Adjust top edge
	        _bounds.size.height = NSMaxY(_bounds) - point.y;
	        _bounds.origin.y = point.y;
	    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob)) {
	        // Adjust bottom edge
	        _bounds.size.height = point.y - _bounds.origin.y;
	    }
	    if (_bounds.size.height < 0.0) { 
	        knob = [DBShape flipKnob:knob horizontal:NO];
	        _bounds.size.height = -_bounds.size.height;
	        _bounds.origin.y -= _bounds.size.height;
	     	[self flipHorizontalyWithNewKnob:knob];
	    } 
    }
	_boundsCenter = _bounds.origin;
	_boundsCenter.x += _boundsSize.width/2;
	_boundsCenter.y += _boundsSize.height/2;
    
    return knob;
}

- (BOOL)changeFillImageDrawPointWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	if(!(([_fill fillMode] == DBImageFillMode && [_fill imageFillMode] == DBDrawMode) || [_fill fillMode] == DBGradientFillMode))
		return NO;
	
	
	NSPoint point, p;
	BOOL canConvert;
	NSAutoreleasePool *pool;     
	
	canConvert = [view isKindOfClass:[DBDrawingView class]];
   
	point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
  
/*	if(canConvert){
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
*/	                     
	p = [_fill imageDrawPoint];
	p.x *= [self zoom];
	p.x += _bounds.origin.x;
	p.y *= [self zoom];
	p.y += _bounds.origin.y;

	if(!DBPointIsOnKnobAtPoint(point,p)){
		return NO;
	}
	
	[self setIsEditing:YES];
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
        
		[view moveMouseRulerMarkerWithEvent:theEvent];

		if(canConvert){
			point = [view pointSnapedToGrid:point];
//			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
	    
		p = point;
		p.x -= _bounds.origin.x;
		p.x /= [self zoom];
		p.y -= _bounds.origin.y;
		p.y /= [self zoom];
		
		[_fill setImageDrawPoint:p];
//		[_layer updateRenderInView:nil];
		
		
		[pool release];
	   	if([theEvent type] == NSLeftMouseUp)
		{
			break;
		}
	}
	[self setIsEditing:NO];
	
	[_layer updateRenderInView:nil];
	
	return YES;
}

- (BOOL)canEdit
{
	return NO;
}

- (BOOL)replaceInView:(DBDrawingView *)view
{
	return NO;
}             

#pragma mark Testing
- (BOOL)hitTest:(NSPoint)point
{
	return NO;
}   

- (BOOL)isInRect:(NSRect)rect
{
	return NSIntersectsRect(rect, _bounds);
}

- (int)knobUnderPoint:(NSPoint)point
{
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(_bounds),NSMinY(_bounds)) ) )
    {
		return UpperLeftKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMaxX(_bounds),NSMinY(_bounds)) ) )
    {
		return  UpperRightKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMaxX(_bounds),NSMaxY(_bounds)) ) )
    {
		return LowerRightKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(_bounds),NSMaxY(_bounds)) ) )
    {
		return LowerLeftKnob;
    } 
 
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(_bounds),NSMinY(_bounds)+NSHeight(_bounds)/2) ) )
    {
		return MiddleLeftKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMaxX(_bounds),NSMinY(_bounds)+NSHeight(_bounds)/2) ) )
    {
		return MiddleRightKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(_bounds)+NSWidth(_bounds)/2,NSMinY(_bounds)) ) )
    {
		return UpperMiddleKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(_bounds)+NSWidth(_bounds)/2,NSMaxY(_bounds)) ) )
    {
		return LowerMiddleKnob;
    }
	
//	NSLog(@"noKnob");
	
	return NoKnob;
}

- (NSPoint)pointForKnob:(int)knob
{
	
	if(knob == UpperLeftKnob)
    {
		return NSMakePoint(NSMinX(_bounds),NSMinY(_bounds));
    }
	if(knob == UpperRightKnob)
    {
		return NSMakePoint(NSMaxX(_bounds),NSMinY(_bounds));
    }
	if(knob == LowerRightKnob)
    {
		return NSMakePoint(NSMaxX(_bounds),NSMaxY(_bounds));
    }
	if(knob == LowerLeftKnob)
    {
		return NSMakePoint(NSMinX(_bounds),NSMaxY(_bounds));
    } 
 
	if(knob == MiddleLeftKnob)
    {
		return NSMakePoint(NSMinX(_bounds),NSMinY(_bounds)+NSHeight(_bounds)/2);
    }
	if(knob == MiddleRightKnob)
    {
		return NSMakePoint(NSMaxX(_bounds),NSMinY(_bounds)+NSHeight(_bounds)/2);
    }
	if(knob == UpperMiddleKnob)
    {
		return NSMakePoint(NSMinX(_bounds)+NSWidth(_bounds)/2,NSMinY(_bounds));
    }
	if(knob == LowerMiddleKnob)
    {
		return NSMakePoint(NSMinX(_bounds)+NSWidth(_bounds)/2,NSMaxY(_bounds));
    }
	
	return NSMakePoint(NSNotFound,NSNotFound);	
}   

#pragma mark Updating Shape
- (void)updateShape
{
	[[[self layer] layerController] updateDependentLayers:[self layer]];
}

- (void)updateFill
{
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	[_fill updateFillForPath:[self path]];   
	[_stroke updateStrokeForPath:[self path]];   
}

- (void)updateBounds
{
	_boundsCenter = _bounds.origin;
	_boundsCenter.x += _boundsSize.width/2;
	_boundsCenter.y += _boundsSize.height/2;
}

- (void)strokeUpdated
{
	if(!_isEditing)
		[_layer updateRenderInView:nil];
    
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES]; 	
}   

- (void)flipVerticallyWithNewKnob:(int)knob
{

}

- (void)flipHorizontalyWithNewKnob:(int)knob
{
	
}

- (void)delete:(id)sender
{
	
}

- (void)addPoint:(id)sender
{
	
}

@end

NSPoint DBMultiplyPointByFactor(NSPoint point, float factor)
{
	return NSMakePoint(point.x*factor,point.y*factor);
}

BOOL DBPointIsOnKnobAtPoint(NSPoint point, NSPoint knobCenter) 
{
	return (sqrt(pow(point.x-knobCenter.x,2)+pow(point.y-knobCenter.y,2)) <= 4);
}

BOOL DBPointIsOnKnobAtPointZoom(NSPoint point, NSPoint knobCenter, float zoom) 
{                 
	if(zoom == 0.0){
		zoom = 1.0;
	}
	return (sqrt(pow(point.x-knobCenter.x,2)+pow(point.y-knobCenter.y,2)) <= 4/zoom);
}

static double distanceBetween(NSPoint a, NSPoint b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  return sqrt (dx * dx + dy * dy);
}

NSPoint resizePoint(NSPoint p, NSPoint oldOrigin, NSPoint newOrigin, float xFactor, float yFactor)
{
	p.x -= oldOrigin.x;
	p.y -= oldOrigin.y;
    
	p.x *= xFactor;
	p.y *= yFactor;

	p.x += newOrigin.x;
	p.y += newOrigin.y;
	
	return p;
}

NSPoint rotatePoint(NSPoint p, NSPoint rotationCenter, float angle)
{
	NSPoint rotatedPoint;
	p.x -= rotationCenter.x;
	p.y -= rotationCenter.y;

	rotatedPoint.x = p.x*cos(angle)-p.y*sin(angle);
	rotatedPoint.y = p.x*sin(angle)+p.y*cos(angle);

	rotatedPoint.x += rotationCenter.x;
	rotatedPoint.y += rotationCenter.y;
	
	return rotatedPoint;
}


