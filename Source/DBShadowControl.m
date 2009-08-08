//
//  DBShadowControl.m
//  ShadowControl
//
//  Created by Raphael Bost on 22/08/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBShadowControl.h"


@implementation DBShadowControl
+ (void)initialize
{
	[self exposeBinding:@"shadowOffsetWidth"];
	[self exposeBinding:@"shadowOffsetHeight"];
	[self exposeBinding:@"shadowBlurRadius"];
	[self exposeBinding:@"shadowColor"];
}

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		
		_shadow = [[NSShadow alloc] init];
		[_shadow setShadowOffset:NSMakeSize(10.0, -10.0)]; 
		[_shadow setShadowBlurRadius:10.0]; 
		[_shadow setShadowColor:[[NSColor blackColor]
		             colorWithAlphaComponent:0.3]];
    }
    return self;
}
 
- (void)dealloc
{
	[_shadow release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect 
{
    // Drawing code here.
	NSRect squareRect;
	NSBezierPath *path;
	NSBezierPath *cursor;
	NSPoint centerPoint = [self offsetPoint];
	
	
	squareRect.size = NSMakeSize(17.0, 17.0);
	squareRect.origin.x = (rect.size.width - squareRect.size.width)/2;
	squareRect.origin.y = (rect.size.height - squareRect.size.height)/2;
	path  = [NSBezierPath bezierPathWithRect:squareRect];
	                             
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:[self bounds]];
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect:NSInsetRect([self bounds],0.5,0.5)];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];   
	
	
	[_shadow set];
	
	[[NSColor whiteColor] set];
	[path fill];
	  
	[[NSGraphicsContext currentContext] restoreGraphicsState];

	[[NSColor blackColor] set];
	[path stroke];
	
	cursor = [[NSBezierPath alloc] init];
	[cursor appendBezierPathWithArcWithCenter:centerPoint radius:[_shadow shadowBlurRadius] startAngle:0.0 endAngle:360.0];
	[[NSColor grayColor] set];
	[cursor stroke];
	[cursor release];
	
	cursor = [[NSBezierPath alloc] init];
	[cursor appendBezierPathWithRect:NSMakeRect(centerPoint.x - 2.5 , centerPoint.y - 2.5, 5.0, 5.0)];
	[[NSColor darkGrayColor] set];
	[cursor fill];
	[[NSColor whiteColor] set];
	[cursor stroke];
	[cursor release];	
}

- (NSPoint)centerPoint
{
	NSRect rect = [self bounds];
	return NSMakePoint((NSMaxX(rect)-NSMinX(rect))/2.0, (NSMaxY(rect)-NSMinY(rect))/2.0);
}

- (NSPoint)offsetPoint
{
	NSPoint centerPoint = [self centerPoint];
	centerPoint.x += [_shadow shadowOffset].width;
	centerPoint.y += [_shadow shadowOffset].height;

	return centerPoint;
}

- (void)setOffsetPoint:(NSPoint)offsetPoint
{
	NSPoint centerPoint = [self centerPoint];
	offsetPoint.x -= centerPoint.x;
	offsetPoint.y -= centerPoint.y;
	
	[self setShadowOffsetWidth:offsetPoint.x];
	[self setShadowOffsetHeight:offsetPoint.y];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	float distanceToCenter, dX, dY;
	NSPoint point, centerPoint;
	
	point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	centerPoint = [self offsetPoint];
	
	dX = point.x - centerPoint.x;
	dY = point.y - centerPoint.y;

	distanceToCenter = sqrt(dX*dX + dY*dY);
	
	if( fabs(distanceToCenter - [_shadow shadowBlurRadius]) <= 1.5 ){
		[self setShadowBlurRadius:distanceToCenter];
 		_trackingTag = 1;

		[[self target] performSelector:[self action] withObject:self];
   	}else if(distanceToCenter <= 3.0){
		[self setOffsetPoint:point];
		_trackingTag = 2;
		
		[[self target] performSelector:[self action] withObject:self];
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	float distanceToCenter, dX, dY;
	NSPoint point, centerPoint;
	
	point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	centerPoint = [self offsetPoint];
	
	dX = point.x - centerPoint.x;
	dY = point.y - centerPoint.y;

	distanceToCenter = sqrt(dX*dX + dY*dY);
	
	if(_trackingTag == 1){
		[self setShadowBlurRadius:distanceToCenter];

		[NSApp sendAction:[self action] to:[self target] from:self];
	}else if(_trackingTag == 2){
		
		if(!NSPointInRect(point, [self bounds])){
			if(point.x > NSMaxX([self bounds])){
				point.x = NSMaxX([self bounds]);
			}else if(point.x < NSMinX([self bounds])){
				point.x = NSMinX([self bounds]);
			}
			if(point.y > NSMaxY([self bounds])){
				point.y = NSMaxY([self bounds]);
			}else if(point.y < NSMinY([self bounds])){
				point.y = NSMinY([self bounds]);
			}
		}
		[self setOffsetPoint:point];
                             
		[NSApp sendAction:[self action] to:[self target] from:self];
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	_trackingTag = 0;
}

- (id)objectValue
{
	return _shadow;
}                   

- (void)setObjectValue:(id)object
{
	if([object isKindOfClass:[NSShadow class]]){
		[object retain];
		[_shadow release];
		_shadow = object;
		
		[self setNeedsDisplay:YES];
	}
}

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if([binding isEqualToString:@"value"]){
		[self bind:@"shadowOffsetWidth" toObject:observableController withKeyPath:@"shadowOffsetWidth" options:options];
		[self bind:@"shadowOffsetHeight" toObject:observableController withKeyPath:@"shadowOffsetHeight" options:options];
		[self bind:@"shadowBlurRadius" toObject:observableController withKeyPath:@"shadowBlurRadius" options:options];
		[self bind:@"shadowColor" toObject:observableController withKeyPath:@"shadowColor" options:options];
		[self bind:@"objectValue" toObject:observableController withKeyPath:@"objectValue" options:options];
	}else{
//		[super bind:binding toObject:observableController withKeyPath:keyPath options:options];
	}
}

- (float)shadowOffsetWidth
{
	return [_shadow shadowOffset].width;
}

- (void)setShadowOffsetWidth:(float)newShadowOffsetWidth
{
	[_shadow setShadowOffset:NSMakeSize(newShadowOffsetWidth, [self shadowOffsetHeight])];
	[self setNeedsDisplay:YES];
}

- (float)shadowOffsetHeight
{
	return [_shadow shadowOffset].height;
}

- (void)setShadowOffsetHeight:(float)newShadowOffsetHeight
{
	[_shadow setShadowOffset:NSMakeSize([self shadowOffsetWidth], newShadowOffsetHeight)];
	[self setNeedsDisplay:YES];
}

- (float)shadowBlurRadius
{
	return [_shadow shadowBlurRadius];
}

- (void)setShadowBlurRadius:(float)newShadowBlurRadius
{
	[self willChangeValueForKey:@"shadowBlurRadius"];

	[_shadow setShadowBlurRadius:newShadowBlurRadius];
	[self setNeedsDisplay:YES];

	[self didChangeValueForKey:@"shadowBlurRadius"];
}

- (NSColor *)shadowColor
{
	return [_shadow shadowColor];
}

- (void)setShadowColor:(NSColor *)newShadowColor
{
	[_shadow setShadowColor:newShadowColor];
	[self setNeedsDisplay:YES];
}

- (id)target
{
	return _target;
}

- (void)setTarget:(id)newTarget
{
	_target = newTarget;
}

- (SEL)action
{
	return _action;
}

- (void)setAction:(SEL)newAction
{
	_action = newAction;
}

@end                        
