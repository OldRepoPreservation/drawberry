//
//  DBGradientCell.m
//  DrawBerry
//
//  Created by Raphael Bost on 25/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBGradientCell.h"


@implementation DBGradientCell
- (void)dealloc
{
	[_gradient release];
	
	[super dealloc];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  	NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame,0.5, 0.5)];
  
/*  	[[NSColor whiteColor] set];
	[path fill];
*/	
	if([self isHighlighted])
		[[GCGradient aquaPressedGradient] fillRect:NSInsetRect(cellFrame,0.5, 0.5)];
	else
		[[GCGradient aquaNormalGradient] fillRect:NSInsetRect(cellFrame,0.5, 0.5)];

  	[[NSColor lightGrayColor] set];
	[path stroke];
	
	[_gradient fillRect:NSInsetRect(cellFrame,3,3)];
}

- (GCGradient *)gradient
{
	return _gradient;
}

- (void)setGradient:(GCGradient *)newGradient
{   
	[newGradient retain];
	[_gradient release];
	_gradient = newGradient;
}



@end
