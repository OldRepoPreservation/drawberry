//
//  DBMagnifyingWindow.m
//  DrawBerry
//
//  Created by Raphael Bost on 02/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBMagnifyingWindow.h"

NSString *DBMagnifyingWindowDidMove = @"DBMagnifyingWindow Did Move";

@implementation DBMagnifyingWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
	
//	_movingFlag = NO;
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBeganToMove:) name:NSWindowWillMoveNotification object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowEndToMove:) name:NSWindowDidMoveNotification object:self];
	[self setMovableByWindowBackground:YES];
	[self setLevel:NSFloatingWindowLevel];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setHasShadow: YES];    
//	[self setShowsResizeIndicator:YES];
	
	return self;
}

- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
} 
 
- (BOOL)isOpaque
{
	return NO;
}
- (void)mouseDragged:(NSEvent *)theEvent
{
	                              
	_movingVec.x += [theEvent deltaX];
	_movingVec.y += [theEvent deltaY];
	[[NSNotificationCenter defaultCenter] postNotificationName:DBMagnifyingWindowDidMove object:self];
	
	[super mouseDragged:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	_movingVec = NSZeroPoint;
	[super mouseUp:theEvent];
}

- (NSRect)frame
{   
	NSRect frame;
	frame = [super frame];
	return NSMakeRect(frame.origin.x+_movingVec.x,frame.origin.y-_movingVec.y,frame.size.width,frame.size.height);
}
/*
- (void)windowBeganToMove:(NSNotification *)note
{
	_movingFlag = YES;
}                     
*/
- (void)windowEndToMove:(NSNotification *)note
{    
	_movingVec = NSZeroPoint;
	[[NSNotificationCenter defaultCenter] postNotificationName:DBMagnifyingWindowDidMove object:self];
}

@end
