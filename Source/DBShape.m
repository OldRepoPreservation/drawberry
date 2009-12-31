//
//  DBShape.m
//  DrawBerry
//
//  Created by Raphael Bost on 10/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBShape.h"
#import "DBLayer.h"

static NSBezierPath *__knob = nil;


@implementation NSColor (InvertColor)

- (NSColor *)colorByInvertingColor
{
	NSColor *rgbColor;
	rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	CGFloat r,g,b,a;
	
	[rgbColor getRed:&r green:&g blue:&b alpha:&a];
	
	return [NSColor colorWithDeviceRed:(1.0-r) green:(1.0-g) blue:(1.0-b) alpha:1.0];
}

@end


@implementation DBShape

+ (NSBezierPath *)knob
{
	if(!__knob){
		__knob = [[NSBezierPath alloc] init];
		[__knob appendBezierPathWithArcWithCenter:NSMakePoint(0,0) radius:4 startAngle:0 endAngle:360];
	}
	return __knob;
}

+ (void)drawBlueKnobAtPoint:(NSPoint)pt 
{
	NSAffineTransform *af = [[NSAffineTransform alloc] init];
	[af translateXBy:pt.x yBy:pt.y];
	[NSGraphicsContext saveGraphicsState];
	[af concat];
	[[NSColor selectedControlColor] set];
	[[self knob] fill];
	[[NSColor alternateSelectedControlColor] set];
	[[self knob] stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[af release];
}

+ (void)drawGrayKnobAtPoint:(NSPoint)pt 
{
	NSAffineTransform *af = [[NSAffineTransform alloc] init];
	[af translateXBy:pt.x yBy:pt.y];
	[NSGraphicsContext saveGraphicsState];
	[af concat];
	[[NSColor lightGrayColor] set];
	[[self knob] fill];
	[[NSColor grayColor] set];
	[[self knob] stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[af release];
}

+ (void)drawSelectedGrayKnobAtPoint:(NSPoint)pt 
{
	NSAffineTransform *af = [[NSAffineTransform alloc] init];
	[af translateXBy:pt.x yBy:pt.y];
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor selectedControlColor] endingColor:[NSColor lightGrayColor]];

	[NSGraphicsContext saveGraphicsState];
	[af concat];
	
	[gradient drawInBezierPath:[self knob] relativeCenterPosition:NSZeroPoint];
	[gradient release];
	
	[[NSColor alternateSelectedControlColor] set];
	[[self knob] stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[af release];
}

+ (void)drawWhiteKnobAtPoint:(NSPoint)pt 
{
	NSAffineTransform *af = [[NSAffineTransform alloc] init];
	[af translateXBy:pt.x yBy:pt.y];
	[NSGraphicsContext saveGraphicsState];
	[af concat];
	[[NSColor whiteColor] set];
	[[self knob] fill];
	[[NSColor lightGrayColor] set];
	[[self knob] stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[af release];
}

+ (void)drawOrangeKnobAtPoint:(NSPoint)pt 
{
	NSAffineTransform *af = [[NSAffineTransform alloc] init];
	[af translateXBy:pt.x yBy:pt.y];
	[NSGraphicsContext saveGraphicsState];
	[af concat];
	[[NSColor yellowColor] set];
	[[self knob] fill];
	[[NSColor orangeColor] set];
	[[self knob] stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[af release];
}

+ (void)drawGreenKnobAtPoint:(NSPoint)pt 
{
	NSAffineTransform *af = [[NSAffineTransform alloc] init];
	[af translateXBy:pt.x yBy:pt.y];
	[NSGraphicsContext saveGraphicsState];
	[af concat];
	[[NSColor greenColor] set];
	[[self knob] fill];
	[[NSColor colorWithCalibratedRed:0.0 green:0.6 blue:0.0 alpha:1.0] set];
	[[self knob] stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[af release];
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
	_shadow = [[DBShadow alloc] initWithShape:self];
	
	_fills = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	[_stroke dealloc];
	[_shadow release]; 
	
	[_fills release];
	
	[super dealloc];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	            
	[self setRotation:[decoder decodeFloatForKey:@"Rotation"]];
		
	_fills = [[decoder decodeObjectForKey:@"Fills"] retain];
	[_fills makeObjectsPerformSelector:@selector(setShape:) withObject:self];
	
	_stroke = [[decoder decodeObjectForKey:@"Stroke"] retain];
	[_stroke setShape:self];
	
	_shadow = [[decoder decodeObjectForKey:@"Shadow"] retain];
	[_shadow setShape:self];
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeFloat:_rotation forKey:@"Rotation"];
	[encoder encodeObject:_fills forKey:@"Fills"];
	[encoder encodeObject:_stroke forKey:@"Stroke"];
	[encoder encodeObject:_shadow forKey:@"Shadow"];
}

#pragma mark Displaying

- (void)drawInView:(NSView *)view rect:(NSRect)rect
{
	
}

- (void)displayEditingKnobs
{
	[_fills makeObjectsPerformSelector:@selector(displayKnobs)];
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
		[DBShape drawOrangeKnobAtPoint:upLeft];
		[DBShape drawOrangeKnobAtPoint:bottomLeft];
		[DBShape drawOrangeKnobAtPoint:upRight];
		[DBShape drawOrangeKnobAtPoint:bottomRight];
		
		[DBShape drawOrangeKnobAtPoint:midLeft];
		[DBShape drawOrangeKnobAtPoint:midRight];
		[DBShape drawOrangeKnobAtPoint:midUp];
		[DBShape drawOrangeKnobAtPoint:midBottom];
	}else{
		[DBShape drawBlueKnobAtPoint:upLeft];
		[DBShape drawBlueKnobAtPoint:bottomLeft];
		[DBShape drawBlueKnobAtPoint:upRight];
		[DBShape drawBlueKnobAtPoint:bottomRight];
		
		[DBShape drawBlueKnobAtPoint:midLeft];
		[DBShape drawBlueKnobAtPoint:midRight];
		[DBShape drawBlueKnobAtPoint:midUp];
		[DBShape drawBlueKnobAtPoint:midBottom];
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
	return NSMakePoint(_bounds.origin.x + _bounds.size.width/2, _bounds.origin.y + _bounds.size.height/2);
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

- (void)addFill:(DBFill *)aFill
{
	[_fills addObject:aFill];
	[aFill setShape:self];
}

- (void)insertFill:(DBFill *)aFill atIndex:(unsigned int)i 
{
	[_fills insertObject:aFill atIndex:i];
	[aFill setShape:self];
}

- (DBFill *)fillAtIndex:(unsigned int)i
{
	return [_fills objectAtIndex:i];
}

- (unsigned int)indexOfFill:(DBFill *)aFill
{
	return [_fills indexOfObject:aFill];
}

- (void)removeFillAtIndex:(unsigned int)i
{
	[_fills removeObjectAtIndex:i];
}

- (void)removeFill:(DBFill *)aFill
{
	[_fills removeObject:aFill];
}

- (unsigned int)countOfFills
{
	return [_fills count];
}

- (NSArray *)fills
{
	return _fills;
}

- (void)setFills:(NSArray *)newFills
{
	[_fills setArray:newFills];
	[_fills makeObjectsPerformSelector:@selector(setShape:) withObject:self];
	[self strokeUpdated];
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

- (DBUndoManager *)undoManager
{
	return [[self layer] undoManager];
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

		float dX2, dY2;
		dY2 = (_bounds.size.width+dX)/ratio - _bounds.size.height;
		dX2 = ratio*(_bounds.size.height+dY) - _bounds.size.width;
		
		if((fabs(dX) < fabs(dY) || (knob == MiddleLeftKnob) || (knob == MiddleRightKnob) ) && (knob != LowerMiddleKnob) && (knob != UpperMiddleKnob) ){
			dY = dY2;
		}else{
			dX = dX2;
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
	
	if(isnan(_bounds.origin.x)){
		_bounds.origin.x = 0;
	}
	if(isnan(_bounds.origin.y)){
		_bounds.origin.y = 0;
	}
	if(isnan(_bounds.size.width)){
		_bounds.size.width = 0;
	}
	if(isnan(_bounds.size.height)){
		_bounds.size.height = 0;
	}
	    
    return knob;
}



- (BOOL)changeFillImageDrawPointWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	NSEnumerator *e;
	DBFill *fill;
	
	e = [_fills reverseObjectEnumerator]; // to get the upper one first
		
	while ((fill = [e nextObject])) {
		if([fill trackMouseWithEvent:theEvent inView:view])
			return YES;
	}
	
	return NO;
}

/*- (BOOL)changeGradientWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	if(![_fill gradientType] == GPRadialType)
	{
		return NO;
	}
	NSPoint point, p;
	BOOL canConvert;
	NSAutoreleasePool *pool;
	int pointFlag;
	BOOL editRadius;
	
	float d1, d2;
	
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	
	point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	
	if(canConvert){
		point = [view pointSnapedToGrid:point];
		point = [view canevasCoordinatesFromViewCoordinates:point];
	}
		  
	
	pointFlag = 0;
	editRadius = NO;
	
	p = [_fill gradientStartingPoint];
	p.x += _bounds.origin.x;
	p.y += _bounds.origin.y;
	
	d1 = distanceBetween(p, point);
	
	if(DBPointIsOnKnobAtPoint(point,p)){
		pointFlag = 1;
		
		if([theEvent modifierFlags] & NSShiftKeyMask){
			editRadius = YES;
		}
	}else{
		p = [_fill gradientEndingPoint];
		p.x += _bounds.origin.x;
		p.y += _bounds.origin.y;
		
		d2 = distanceBetween(p, point);

		if(DBPointIsOnKnobAtPoint(point,p)){
			pointFlag = 2;
			
			if([theEvent modifierFlags] & NSShiftKeyMask){
				editRadius = YES;
			}
			
		}else{			
			if(d1 <= [_fill gradientStartingRadius] + 1.5 && d1 >= [_fill gradientStartingRadius] - 1.5){
				pointFlag = 1;
				editRadius = YES;
			}else if(d2 <= [_fill gradientEndingRadius] + 1.5 && d2 >= [_fill gradientEndingRadius] - 1.5){
				pointFlag = 2;
				editRadius = YES;
			}else{
				pointFlag = 0;
				return NO;
			}
			
		}
	}
	
	
	
	[self setIsEditing:YES];
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
		
		[view moveMouseRulerMarkerWithEvent:theEvent];
		
		if(canConvert){
			point = [view pointSnapedToGrid:point];
			point = [view canevasCoordinatesFromViewCoordinates:point];
		}
	    
		p = point;
		p.x -= _bounds.origin.x;
		p.y -= _bounds.origin.y;
		
		if(pointFlag == 1){
			if(editRadius){
				[_fill setGradientStartingRadius:distanceBetween(p, [_fill gradientStartingPoint])];
			}else{
				[_fill setGradientStartingPoint:p];
			}
		}else{
			if(editRadius){
				[_fill setGradientEndingRadius:distanceBetween(p, [_fill gradientEndingPoint])];
			}else{
				[_fill setGradientEndingPoint:p];
			}
		}
			
		
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
*/
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

- (BOOL)isNaN
{
	return isnan(_bounds.origin.x) || isnan(_bounds.origin.y) || isnan(_bounds.size.width) || isnan(_bounds.size.height);
}

#pragma mark Updating Shape
- (void)updateShape
{
	[[[self layer] layerController] updateDependentLayers:[self layer]];
}

- (void)updateFill
{
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	[_fills makeObjectsPerformSelector:@selector(updateFillForPath:) withObject:[self path]];
	[_stroke updateStrokeForPath:[self path]];   
}

- (void)updateBounds
{
}

- (void)updatePath
{
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

#pragma mark Fill and Stroke

- (void)applyFillsToPath:(NSBezierPath *)path
{
	[_fills makeObjectsPerformSelector:@selector(fillPath:) withObject:path];
}

#pragma mark Transform

- (void)applyTransform:(NSAffineTransform *)at
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
	float d = pow(point.x-knobCenter.x,2)+pow(point.y-knobCenter.y,2);
	return (d <= (4*zoom)*(4*zoom));
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


