//
//  DBMagnifyingView.m
//  DrawBerry
//
//  Created by Raphael Bost on 01/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBMagnifyingView.h"
#import "DBMagnifyingWindow.h"

@interface NSView (Zoom)
- (float)zoom;
- (void)setZoomWithoutDisplay:(float)newZoom;
@end                                         

@implementation DBMagnifyingView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidMove:) name:DBMagnifyingWindowDidMove object:[self window]];
	
	_zoom = 1.0;
	_magType = 101;
	
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect sourceRect;
	NSPoint center;
	NSAffineTransform *transform;
	float oldZoom = [_source zoom];
	float radius;
   	
	center = NSMakePoint([self frame].size.width/2-1.0, ([self frame].size.height)/2-1.0); 
	radius = MIN([self frame].size.width,[self frame].size.height)/2-0.5;
	
	sourceRect.size.width = [self frame].size.width /*/ _zoom*/;
	sourceRect.size.height = [self frame].size.height /*/ _zoom*/;
	
	if(_magType == DBPixellisationMagnifyingType){
		sourceRect.size.width /= _zoom;
		sourceRect.size.height /=_zoom;
	}
	
	sourceRect.origin = _magnifyingPoint;
	sourceRect.origin.x -= sourceRect.size.width /2.0;
	sourceRect.origin.y -= sourceRect.size.height /2.0;
                                
	[NSGraphicsContext saveGraphicsState];   

	[[NSColor clearColor] set];
	[NSBezierPath fillRect:[self frame]];

	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeClear];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:[self frame]];
	
	NSBezierPath *circle = [[NSBezierPath alloc] init];
	[circle appendBezierPathWithArcWithCenter:center radius:radius-10.0 startAngle:0 endAngle:360];
	[circle fill];

	NSBezierPath *back = [[NSBezierPath alloc] init];
	[back appendBezierPathWithRect:[self frame]];
	[back appendBezierPath:circle];
	[back setWindingRule:NSEvenOddWindingRule];

	transform = [NSAffineTransform transform];

	if(_magType == DBPixellisationMagnifyingType){
		[transform scaleBy:_zoom];
	}else if(_magType == DBVectorialMagnifyingType){
		[_source setZoomWithoutDisplay:_zoom];
	}

	[transform translateXBy:-sourceRect.origin.x yBy:-sourceRect.origin.y];
	
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
	[[NSColor whiteColor] set];
	[circle fill];

	[transform concat];
	
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceIn];
	
	_isDrawing = YES;
	[_source drawRect:sourceRect];
	_isDrawing = NO;
	
	[transform invert];
	[transform concat];

	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeClear];
	[[NSColor blueColor] set];
	[back fill];
	
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
	[[NSColor lightGrayColor] set];
	[circle stroke];
	
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeDestinationAtop];
	[circle release];
	circle = [[NSBezierPath alloc] init];
	//[circle appendBezierPathWithArcWithCenter:NSMakePoint([self frame].size.width/2, [self frame].size.height/2) radius:MIN([self frame].size.width,[self frame].size.height)/2 startAngle:0 endAngle:360];
	[circle appendBezierPathWithArcWithCenter:center radius:radius startAngle:90 endAngle:0 clockwise:NO];
	[circle lineToPoint:NSMakePoint(center.x+radius,center.y + radius-7.0)];
	[circle appendBezierPathWithArcWithCenter:NSMakePoint(center.x+radius-7.0,center.y + radius - 7.0) radius:7.0 startAngle:0 endAngle:90 clockwise:NO];
	[circle lineToPoint:NSMakePoint(center.x,center.y + radius)];
	[circle closePath];
	
	[[NSColor colorWithCalibratedRed:0.12549 green:0.12549 blue:0.12549 alpha:0.95] set];
	[circle fill];
	[[NSColor colorWithCalibratedRed:.479182 green:.479182 blue:.479182 alpha:0.5] set];
	[circle stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[_source setZoomWithoutDisplay:oldZoom];
	
	
	[circle release];
	[back release];
	
	NSPoint resizeOrigin = NSMakePoint(NSMaxX([self frame]) - 5,NSMaxY([self frame]) - 5);
	NSBezierPath *resizeGrip = [NSBezierPath bezierPath];
	[resizeGrip moveToPoint:NSMakePoint(resizeOrigin.x, resizeOrigin.y - 2)];
	[resizeGrip lineToPoint:NSMakePoint(resizeOrigin.x - 3, resizeOrigin.y)];
	[resizeGrip moveToPoint:NSMakePoint(resizeOrigin.x, resizeOrigin.y - 6)];
	[resizeGrip lineToPoint:NSMakePoint(resizeOrigin.x - 7, resizeOrigin.y)];
	[resizeGrip moveToPoint:NSMakePoint(resizeOrigin.x, resizeOrigin.y - 10)];
	[resizeGrip lineToPoint:NSMakePoint(resizeOrigin.x - 11, resizeOrigin.y)];		
	[resizeGrip setLineWidth:1.0];
	
	[[NSColor lightGrayColor] set];
	[resizeGrip stroke];	
}

- (BOOL)isOpaque
{
	return NO;
}

- (NSView *)source
{
	return _source;
}

- (void)setSource:(NSView *)newSource
{
	if(_source != newSource){
		_source = newSource;
		[self correctMagPoint];
		[self setNeedsDisplay:YES];
	}
}

- (NSPoint)magnifyingPoint
{
	return _magnifyingPoint;
}

- (void)setMagnifyingPoint:(NSPoint)newMagnifyingPoint
{
	if(!NSEqualPoints(_magnifyingPoint, newMagnifyingPoint))
	{             
		_magnifyingPoint = newMagnifyingPoint;
		[self correctWindowPlace];
		[self setNeedsDisplay:YES];
	}
}

- (float)zoom
{
	return _zoom;
}

- (void)setZoom:(float)newZoom
{
    if(_zoom != newZoom && newZoom != 0){
	 	_zoom = newZoom;
		[self setNeedsDisplay:YES];
    }
}

- (DBMagnifyingType)magnifyingType
{
	return _magType;
}

- (void)setMagnifyingType:(DBMagnifyingType)newMagnifyingType
{
	_magType = newMagnifyingType;
	[self setNeedsDisplay:YES];
}

- (BOOL)isFlipped
{
	return YES;
 	return [_source isFlipped];
}

- (NSRect)sourceZoomedRect
{
	NSRect sourceRect;
	
	sourceRect.size.width = [self frame].size.width /*/ _zoom*/;
	sourceRect.size.height = [self frame].size.height /*/ _zoom*/;
	
	if(_magType == DBPixellisationMagnifyingType){
		sourceRect.size.width /= _zoom;
		sourceRect.size.height /=_zoom;
	}
	
	sourceRect.origin = _magnifyingPoint;
	sourceRect.origin.x -= sourceRect.size.width /2.0;
	sourceRect.origin.y -= sourceRect.size.height /2.0;
	
	return sourceRect;
}

- (BOOL)isDrawingSource
{
	return _isDrawing;
}

- (IBAction)takeZoomValueFrom:(id)sender
{
	[self setZoom:[[sender selectedItem] tag]/100.0];
}

- (IBAction)update:(id)sender
{
	[self setNeedsDisplay:YES];
}                              

- (void)correctWindowPlace
{
	NSPoint centerPoint;
	// centerPoint.x = [self frame].size.width/2.0;
	// centerPoint.y = [self frame].size.height/2.0;
	// centerPoint = [self convertPoint:centerPoint toView:nil];
	// centerPoint = [[self window] convertBaseToScreen:centerPoint];
    
	centerPoint = [_source convertPoint:_magnifyingPoint toView:nil];
	centerPoint = [[_source window] convertBaseToScreen:centerPoint];
	centerPoint.x -= [[self window] frame].size.width/2.0;
	centerPoint.y -= [[self window] frame].size.height/2.0;
	
	[[self window] setFrameOrigin:centerPoint];
}

- (void)correctMagPoint
{
 	NSPoint centerPoint;
	
	centerPoint = [[self window] frame].origin;
	centerPoint.x += [[self window] frame].size.width/2.0;
	centerPoint.y += [[self window] frame].size.height/2.0;
	
	centerPoint = [[_source window] convertScreenToBase:centerPoint];
	_magnifyingPoint = [_source convertPoint:centerPoint fromView:nil];   
}                                                                      

- (void)windowDidMove:(NSNotification *)aNotification
{
	// update the source point
	
	[self correctMagPoint];                
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSRect resizeRect;                
	NSPoint point;
  	
	resizeRect.origin = NSMakePoint(NSMaxX([self frame]) - 17,NSMaxY([self frame]) - 17);
	resizeRect.size = NSMakeSize(15,16);
	
	point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	if(NSPointInRect(point, resizeRect)){
		_isResizing = YES;
	}else{
		[super mouseDown:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	_isResizing = NO;
	[super mouseUp:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if(_isResizing){
		NSRect newFrame, oldFrame;
		float delta;
		delta = MIN([theEvent deltaX], [theEvent deltaY]);
		oldFrame = [[self window] frame];      
		newFrame = oldFrame;
/*		                                       
		newFrame.size.width += [theEvent deltaX];
		newFrame.origin.y -= [theEvent deltaY];
		newFrame.size.height += [theEvent deltaY];
		newFrame.size.width = MIN(newFrame.size.width,oldFrame.size.height+[theEvent deltaY]);

		newFrame.size.height += newFrame.size.width - oldFrame.size.height;
		newFrame.origin.y -= newFrame.size.width - oldFrame.size.height;
*/		
		float dX = [theEvent deltaX], dY = [theEvent deltaY];
		float ratio = 1.0;
		
		if( fabs(dX) < fabs(dY)  ){
			dY = (oldFrame.size.width+dX)/ratio - oldFrame.size.height;
		}else{
			dX = ratio*(oldFrame.size.height+dY) - oldFrame.size.width;
   		}
		
		if(oldFrame.size.width + dX >= 230){
//			dX = 230 - oldFrame.size.width;
			newFrame.size.width += dX;
		}
		if(oldFrame.size.height + dY >= 230){
//			dY = 230 - oldFrame.size.height;
			newFrame.origin.y -= dY;
			newFrame.size.height += dY;
		}
		
//		newFrame.size.width += dX;
		// newFrame.origin.y -= dY;
		// newFrame.size.height += dY;
		                                       
		[[self window] setFrame:newFrame display:YES animate:NO];
	}else{
		[super mouseDragged:theEvent];
	}
}
@end
