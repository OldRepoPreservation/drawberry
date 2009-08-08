//
//  DBMenuButton.m
//  DrawBerry
//
//  Created by Raphael Bost on 09/07/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBMenuButton.h"


@implementation DBMenuButton

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
	
	[NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
}
@end
