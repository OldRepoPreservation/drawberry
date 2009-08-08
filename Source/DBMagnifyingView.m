//
//  DBMagnifyingView.m
//  DrawBerry
//
//  Created by Raphael Bost on 01/09/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBMagnifyingView.h"
#import "DBMagnifyingWindow.h"

@interface NSView (Zoom)
- (float)zoom;
- (void)setZoomWithoutDisplay:(float)newZoom;
@end                                         


#define DBSliderWidth 4.f

#define DBSliderKnobRadius 6.f

@interface DBMagnifyingView (Private)
-(NSColor *)strokeColor;
-(NSColor *)disabledStrokeColor;
-(NSGradient *)knobColor;
-(NSGradient *)highlightKnobColor;
-(NSGradient *)disabledKnobColor;
-(NSGradient *)disabledKnobColor;
-(NSShadow *)dropShadow;
-(NSShadow *)focusRing;
@end

float DAngleBetweenPoints(NSPoint center, NSPoint point1, NSPoint point2){
 	double u1,u2,v1,v2;
	
	u1 = point1.x - center.x;
	u2 = point1.y - center.y;
	v1 = point2.x - center.x;
	v2 = point2.y - center.y;
	
	double cosTheta, normeU, normeV;
	float theta;
	normeU = sqrt(u1*u1 + u2*u2);
	normeV = sqrt(v1*v1 + v2*v2);
	
	
	cosTheta = u1/normeU;
	theta = acos(cosTheta);
	cosTheta = v1/normeV;
	
	if((u2 < 0 && v2 >= 0) || (v2 < 0 && u2 >= 0))
		theta += acos(cosTheta);
	else
		theta -= acos(cosTheta);
	
	if(u2 >= 0){
		theta = 2*M_PI-theta;
	}
	
	return theta;
}    

@implementation DBMagnifyingView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidMove:) name:DBMagnifyingWindowDidMove object:[self window]];
	
	_zoom = 0.0;
	
	_startAngle = 225; //min value
	_startAngle = 270;
	
	_endAngle = 90; //max value
	_endAngle = 0;
	_isHighlighted = NO;
	
	return self;
}

- (void)awakeFromNib
{
	[self setZoom:2.0];
}

- (void)drawRect:(NSRect)rect
{
	NSRect sourceRect;
	NSPoint center;
	NSAffineTransform *transform;
	float radius;
   	
	center = NSMakePoint([self frame].size.width/2-1.0, ([self frame].size.height)/2-1.0); 
	radius = MIN([self frame].size.width,[self frame].size.height)/2-0.5;
	
	sourceRect.size.width = [self frame].size.width;
	sourceRect.size.height = [self frame].size.height;
	
	sourceRect.size.width /= _zoom;
	sourceRect.size.height /=_zoom;
	
	sourceRect.origin = _magnifyingPoint;
	sourceRect.origin.x -= sourceRect.size.width /2.0;
	sourceRect.origin.y -= sourceRect.size.height /2.0;
    
	NSBezierPath *circle = [[NSBezierPath alloc] init];
	[circle appendBezierPathWithArcWithCenter:center radius:radius-10.0 startAngle:0 endAngle:360];
	
	NSBezierPath *back = [[NSBezierPath alloc] init];
	[back appendBezierPathWithRect:[self frame]];
	[back appendBezierPath:circle];
	[back setWindingRule:NSEvenOddWindingRule];

	[NSGraphicsContext saveGraphicsState];   
	
	[circle addClip];
	transform = [NSAffineTransform transform];

	[transform scaleBy:_zoom];
		
	[transform translateXBy:-sourceRect.origin.x yBy:-sourceRect.origin.y];
	
	[transform concat];
		
	_isDrawing = YES;
	[_source drawRect:sourceRect];
	_isDrawing = NO;
	
	[NSGraphicsContext restoreGraphicsState]; 
		
	[circle release];
	[back release];
	
	[self drawSlider];
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
		[self setFloatValue:_zoom];
		[self setNeedsDisplay:YES];
				
		[_zoomField setStringValue:[NSString stringWithFormat:@"%d %%",((int)(_zoom*10)*10)]];
    }
}

- (BOOL)isFlipped
{
	if(_source)
		return [_source isFlipped];
	return YES;
}

- (NSRect)sourceZoomedRect
{
	NSRect sourceRect;
	
	sourceRect.size.width = [self frame].size.width /*/ _zoom*/;
	sourceRect.size.height = [self frame].size.height /*/ _zoom*/;
	
	sourceRect.size.width /= _zoom;
	sourceRect.size.height /=_zoom;

	
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
	if(!_source){
		return;
	}
	NSLog(@"correct window place");
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
//	NSLog(@"correct mag point %@",NSStringFromRect([[self window] frame]));

 	NSPoint centerPoint;
	
	centerPoint = [self bounds].origin;
	centerPoint.x += [self bounds].size.width/2 + [(DBMagnifyingWindow*)[self window] movingVect].x;
	centerPoint.y += [self bounds].size.height/2 + [(DBMagnifyingWindow*)[self window] movingVect].y;
	
	centerPoint = [self convertPoint:centerPoint toView:nil];
	centerPoint = [[self window] convertBaseToScreen:centerPoint];
	
	centerPoint = [[_source window] convertScreenToBase:centerPoint];
	_magnifyingPoint = [_source convertPoint:centerPoint fromView:nil];   
}                                                                      

- (void)windowDidMove:(NSNotification *)aNotification
{
	// update the source point
	
	[self correctMagPoint];    
//	[self correctWindowPlace];

	[self setNeedsDisplay:YES];
}

#pragma mark Slider

- (void)drawSlider
{
	float radius;
	NSPoint center;
	
	radius = [self sliderRadius];
	center = [self bounds].origin;
	center.x += ceilf (([self bounds].size.width)/2.0) -1.0;
	center.y += ceilf (([self bounds].size.height)/2.0) -1.0;
	
	NSBezierPath *arc;
	
	arc = [NSBezierPath bezierPath];
	[arc appendBezierPathWithArcWithCenter:center radius:(radius-DBSliderWidth/2.f) startAngle:-_startAngle endAngle:-_endAngle clockwise:NO];	
	[arc appendBezierPathWithArcWithCenter:NSMakePoint(radius*cos(-_endAngle*(M_PI/180.f))+center.x, radius*sin(-_endAngle*(M_PI/180.f))+center.y)
									radius:DBSliderWidth/2.f startAngle:-_endAngle+180 endAngle:-_endAngle clockwise:YES];
	
	[arc appendBezierPathWithArcWithCenter:center radius:(radius+DBSliderWidth/2.f) startAngle:-_endAngle endAngle:-_startAngle clockwise:YES];
	
	[arc appendBezierPathWithArcWithCenter:NSMakePoint(radius*cos(-_startAngle*(M_PI/180.f))+center.x, radius*sin(-_startAngle*(M_PI/180.f))+center.y)
									radius:DBSliderWidth/2.f startAngle:-_startAngle  endAngle:-_startAngle+180 clockwise:YES];
	
	
	[[NSColor colorWithDeviceRed: 0.318 green: 0.318 blue: 0.318 alpha:0.7] set];
	[arc fill];
	[[NSColor colorWithDeviceRed: 0.749 green: 0.761 blue: 0.788 alpha:0.7] set];
	[arc stroke];
	
	float angle;
	
	angle = _startAngle + (_endAngle - _startAngle)*([self floatValue] - [self minValue])/([self maxValue] - [self minValue]);
	
	[self drawKnobAtPoint:NSMakePoint(radius*cos(-angle*(M_PI/180.f))+center.x, radius*sin(-angle*(M_PI/180.f))+center.y)];	
}

- (void)drawKnobAtPoint:(NSPoint)p
{
	NSBezierPath *knob;
	float angle;
	
	angle = _startAngle + (_endAngle - _startAngle)*([self floatValue] - [self minValue])/([self maxValue] - [self minValue]);
	
	knob = [NSBezierPath bezierPath];
	[knob appendBezierPathWithArcWithCenter:p radius:DBSliderKnobRadius startAngle:0 endAngle:360 clockwise:NO];
	
	if([self isEnabled]) {
		
		[NSGraphicsContext saveGraphicsState];
		
		if([self isHighlighted] && ([self focusRingType] == NSFocusRingTypeDefault ||
									[self focusRingType] == NSFocusRingTypeExterior)) {
			[[self focusRing] set];
		}else{
			[[self dropShadow] set];
		}
	}
	
	if ([self isEnabled]) {
		if([self isHighlighted]){
			[[self highlightKnobColor] drawInBezierPath:knob angle:90];
		}else{
			[[self knobColor] drawInBezierPath:knob angle:90];
		}
		[[self strokeColor] set];
	}else{
		[[self disabledKnobColor] drawInBezierPath:knob angle:90];
		[[self disabledStrokeColor] set];
		
	}
	[knob stroke];
	
	[NSGraphicsContext restoreGraphicsState];
}


- (BOOL)isHighlighted
{
	return _isHighlighted;
}

- (float)sliderRadius
{
	return (MIN([self frame].size.width,[self frame].size.height) - DBSliderWidth - DBSliderKnobRadius - 2.0)/2.0f;
}

- (NSPoint)centerPoint
{
	NSPoint center;
	center = [self bounds].origin;
	center.x += ceilf (([self bounds].size.width)/2.0);
	center.y += ceilf (([self bounds].size.height)/2.0);
	
	return center;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	
	if([self isEnabled]){
		float angle, d;
		NSPoint p, knobPoint;
		
		angle = _startAngle + (_endAngle - _startAngle)*([self floatValue] - [self minValue])/([self maxValue] - [self minValue]);
		p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		knobPoint = [self centerPoint];
		knobPoint.x += [self sliderRadius]*cos(-angle*(M_PI/180.f));
		knobPoint.y += [self sliderRadius]*sin(-angle*(M_PI/180.f));
		
		d = ((p.x - knobPoint.x)*(p.x - knobPoint.x) + (p.y - knobPoint.y)*(p.y - knobPoint.y));
		
		if( d <= DBSliderKnobRadius*DBSliderKnobRadius){
			_isHighlighted = YES;
			_isDragging = YES;
			[self setNeedsDisplay:YES];			
		}else{
			[super mouseDown:theEvent];
		}
	}else {
		[super mouseDown:theEvent];
	}
	
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if([self isEnabled] && _isDragging){
		_isHighlighted = YES;
		
		NSPoint p,center, refPoint;
		float angle, value;
		
		p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		
		center = [self bounds].origin;
		center.x += ceilf (([self bounds].size.width)/2.0);
		center.y += ceilf (([self bounds].size.height)/2.0);
		
		refPoint = NSMakePoint([self sliderRadius]*cos(-_startAngle*(M_PI/180.f)), [self sliderRadius]*sin(-_startAngle*(M_PI/180.f)));
		
		angle = DAngleBetweenPoints(center,p,NSMakePoint(1.0+center.x, 0.0+center.y));
		value = ([self maxValue] - [self minValue])*(angle*(180.f/M_PI)-_startAngle)/(_endAngle - _startAngle) + [self minValue];		
		
		[self setFloatValue:value];
		
		[self setNeedsDisplay:YES];
		
	}else {
		[super mouseDragged:theEvent];		
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if([self isEnabled] && _isDragging){
		_isHighlighted = NO;
		_isDragging = NO;
		
		[self setNeedsDisplay:YES];
	}else {
		[super mouseUp:theEvent];
	}
	
}

- (float)floatValue
{
	return _floatValue;
}
- (void)setFloatValue:(float)f
{
	_floatValue = MAX( MIN(f,[self maxValue]), [self minValue]);
	
	[self setZoom:_floatValue];
	[self setNeedsDisplay:YES];
}

- (float)minValue
{
	return 1.0;
}

- (float)maxValue
{
	return 16.0;
}

- (BOOL)isEnabled
{
	return YES;
}
#pragma mark  Colors and Gradients
-(NSColor *)strokeColor {
	
	return [NSColor colorWithDeviceRed: 0.749 green: 0.761 blue: 0.788 alpha: 0.7];
}

-(NSColor *)disabledStrokeColor {
	
	return [NSColor colorWithDeviceRed: 0.749 green: 0.761 blue: 0.788 alpha: 0.2];
}

-(NSGradient *)knobColor {
	
	return [[[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.324 green: 0.331 blue: 0.347 alpha: 1.0],
			 (CGFloat)0, [NSColor colorWithDeviceRed: 0.245 green: 0.253 blue: 0.269 alpha: 1.0], (CGFloat).5,
			 [NSColor colorWithDeviceRed: 0.206 green: 0.214 blue: 0.233 alpha: 1.0], (CGFloat).5,
			 [NSColor colorWithDeviceRed: 0.139 green: 0.147 blue: 0.167 alpha: 1.0], (CGFloat)1.0, nil] autorelease];
}

-(NSGradient *)highlightKnobColor {
	
	return [[[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.524 green: 0.531 blue: 0.547 alpha: 1.0],
			 (CGFloat)0, [NSColor colorWithDeviceRed: 0.445 green: 0.453 blue: 0.469 alpha: 1.0], (CGFloat).5,
			 [NSColor colorWithDeviceRed: 0.406 green: 0.414 blue: 0.433 alpha: 1.0], (CGFloat).5,
			 [NSColor colorWithDeviceRed: 0.339 green: 0.347 blue: 0.367 alpha: 1.0], (CGFloat)1.0, nil] autorelease];
}

-(NSGradient *)disabledKnobColor {
	
	return [[[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.324 green: 0.331 blue: 0.347 alpha: 1.0],
			 (CGFloat)0, [NSColor colorWithDeviceRed: 0.245 green: 0.253 blue: 0.269 alpha: 1.0], (CGFloat).5,
			 [NSColor colorWithDeviceRed: 0.206 green: 0.214 blue: 0.233 alpha: 1.0], (CGFloat).5,
			 [NSColor colorWithDeviceRed: 0.139 green: 0.147 blue: 0.167 alpha: 1.0], (CGFloat)1.0, nil] autorelease];
}

-(NSShadow *)dropShadow {
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor: [NSColor blackColor]];
	[shadow setShadowBlurRadius: 2];
	[shadow setShadowOffset: NSMakeSize( 0, -1)];
	
	return [shadow autorelease];
}

-(NSShadow *)focusRing {
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor: [NSColor whiteColor]];
	[shadow setShadowBlurRadius: 3];
	[shadow setShadowOffset: NSMakeSize( 0, 0)];
	
	return [shadow autorelease];
}

@end
