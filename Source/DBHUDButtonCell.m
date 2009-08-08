//
//  DBHUDButtonCell.m
//  DrawBerry
//
//  Created by Raphael Bost on 09/08/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBHUDButtonCell.h"


@implementation DBHUDButtonCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{    
//	[super drawWithFrame:cellFrame inView:controlView];
	
	NSImage *backgroundImage;
	NSPoint point;
	NSSize imageSize;
	
	
	backgroundImage = [NSImage imageNamed:@"button_glass"];
	imageSize = cellFrame.size;
//	imageSize.width -= 4.0;
//	imageSize.height -= 4.0;
	
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	[backgroundImage setSize:imageSize];
	
	point = cellFrame.origin;
//	point.x +=2;
//	point.y +=2;
	
	[backgroundImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
//	[super drawWithFrame:cellFrame inView:controlView];
	[[NSColor greenColor] set];
	[NSBezierPath fillRect:cellFrame];
}

@end
