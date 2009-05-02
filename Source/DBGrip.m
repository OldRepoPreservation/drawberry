//
//  DBGrip.m
//  DrawBerry
//
//  Created by Raphael Bost on 03/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DBGrip.h"

#define	BarHeight 60

@implementation DBGrip

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	
	[[NSColor redColor] set];
//	[NSBezierPath fillRect:rect];
	
	NSBezierPath *grip;
	grip = [[NSBezierPath alloc] init];
	float width, height;
	width = [self bounds].size.width;
	height = [self bounds].size.height;
	
	[grip moveToPoint:NSMakePoint(width-8.5, height-BarHeight)];
	[grip lineToPoint:NSMakePoint(width-8.5, height)];
	[grip moveToPoint:NSMakePoint(width-6.5, height-BarHeight+4.0)];
	[grip lineToPoint:NSMakePoint(width-6.5, height-4.0)];
	[grip moveToPoint:NSMakePoint(width-4.5, height-BarHeight+10.0)];
	[grip lineToPoint:NSMakePoint(width-4.5, height-10.0)];
	[grip moveToPoint:NSMakePoint(width-2.5, height-BarHeight+16.0)];
	[grip lineToPoint:NSMakePoint(width-2.5, height-16.0)];
	
	[[NSColor colorWithDeviceRed: 0.749 green: 0.761 blue: 0.788 alpha: 0.7] set];
	[grip stroke];
	
	[grip release];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	_isDragging = YES;

//	[[NSCursor closedHandCursor] push];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSRect frame;
	frame = [[self window] frame];
	
	frame.origin.x += [theEvent deltaX];
	frame.origin.y -= [theEvent deltaY];
	
	[[self window] setFrame:frame display:YES];
	
	_isDragging = YES;
}

- (void)mouseUp:(NSEvent *)theEvent
{
	_isDragging = NO;
//	[NSCursor pop];
}
@end
