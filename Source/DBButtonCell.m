//
//  DBButtonCell.m
//  DrawBerry
//
//  Created by Raphael Bost on 12/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBButtonCell.h"


@implementation DBButtonCell
- (BOOL)isLocked
{
	return _locked;
}

- (void)setLocked:(BOOL)newLocked
{
	_locked = newLocked;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
//	[super drawWithFrame:cellFrame inView:controlView];
	
	NSImage *backgroundImage, *image;
	NSPoint point;
	NSSize imageSize;
	

//	NSLog(@"state %@: %d, %d",[self title], [self state], [self isHighlighted]);
//	backgroundImage = [NSImage imageNamed:@"button_highlighted"];
	
	if([self isLocked]){
		backgroundImage =  [NSImage imageNamed:@"button_selected"];		
	}else if([self state] == NSOnState){
		backgroundImage = [NSImage imageNamed:@"button_highlighted"];
	}else{
//		backgroundImage = [NSImage imageNamed:@"button_glassbis"];
		backgroundImage = nil;
		//[backgroundImage setFlipped:YES];
	}
	
	// rect.origin = NSZeroPoint;
	// rect.size = imageSize;
	// rect = NSInsetRect(rect,1,1);	
	
	imageSize = cellFrame.size;
	imageSize.width -= 4.0;
	imageSize.height -= 4.0;
	
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	[backgroundImage setSize:imageSize];
	
	point = cellFrame.origin;
	point.x +=2;
	point.y +=2;
	
	[backgroundImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	[[NSColor colorWithCalibratedRed:.592 green:.592 blue:.592 alpha:1.0] set];
	[NSBezierPath strokeRect:NSInsetRect(cellFrame,2.5,2.5)];
	
	image = [self image];
	imageSize = [image size]; 
	
	point.x = floorf(MAX(cellFrame.size.width - imageSize.width, 0)/2.0 + cellFrame.origin.x);
	point.y = floorf(MAX(cellFrame.size.height - imageSize.height, 0)/2.0 + cellFrame.origin.y);	
	
	[image setFlipped:YES];
	[image drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}
@end
