//
//  DBPopUpButton.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBPopUpButton.h"


@implementation DBPopUpButton
- (void)awakeFromNib
{                  
	NSRect frame;
	frame = [self frame];
	[self setFrame:NSMakeRect(frame.origin.x,frame.origin.y - (30 - frame.size.height)/2 +1 ,frame.size.width,30)];
}

- (void)dealloc
{	
	[_image release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{    
	[_image setFlipped:YES];
	[_image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (NSImage *)image
{
	return _image;
}

- (void)setImage:(NSImage *)newImage
{
	[newImage retain];
	[_image release];
	_image = newImage;
}
@end
