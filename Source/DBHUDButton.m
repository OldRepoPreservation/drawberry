//
//  DBHUDButton.m
//  DrawBerry
//
//  Created by Raphael Bost on 09/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBHUDButton.h"
#import "DBHUDButtonCell.h"


@implementation DBHUDButton
// + (Class)cellClass
// {
// 	return [DBHUDButtonCell class];
// }


- (void)drawRect:(NSRect)r
{
//	[[NSColor greenColor] set];
//	[NSBezierPath fillRect:r];
	
	NSImage *backgroundImage = nil;
	NSPoint point;
	NSSize imageSize;


	if([[self cell] isHighlighted]){
		backgroundImage = [NSImage imageNamed:@"button_glass_p"];
		[backgroundImage setFlipped:YES];
	}else{	
		backgroundImage = [NSImage imageNamed:@"button_glass"];
	}
	imageSize = [self frame].size;
    
	[backgroundImage setScalesWhenResized:YES];
	[backgroundImage setSize:imageSize];


	[backgroundImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
	NSAttributedString *string;
	NSDictionary *att;
	
	att = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:10],NSFontAttributeName,
													   [NSColor whiteColor],NSForegroundColorAttributeName,
													   nil];
	
//	string = [self attributedTitle];
	string = [[NSAttributedString alloc] initWithString:[self title] attributes:att];
	point.x = ([self frame].size.width - [string size].width)/2;
	point.y = ([self frame].size.height - [string size].height)/2;

	[string drawAtPoint:point];
	
	[att release];
	[string release];
} 

@end
