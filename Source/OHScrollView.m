//
//  OHScrollView.m
//  OpenHUD
//
//  Created by Andy Matuschak on 11/6/05.
//  Copyright 2005 Andy Matuschak. All rights reserved.
//

#import "OHScrollView.h"
#import "OHScroller.h"


@implementation OHScrollView

- (void)setup
{
	[self setVerticalScroller:[[OHScroller alloc] initWithFrame:[[self verticalScroller] frame]]];
	[self setHorizontalScroller:[[OHScroller alloc] initWithFrame:[[self horizontalScroller] frame]]];
	[self reflectScrolledClipView:[self contentView]]; // Forces the scroll view to realize it has new scrollers; redisplays them. A simple setNeedsDisplay: call doesn't work for some reason.
	
	[self setBackgroundColor:[NSColor blackColor]];
	[self _setLineBorderColor:[NSColor whiteColor]]; // warning: private!
}

- initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	[self setup];
	return self;
}

- initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	[self setup];
	return self;
}

@end
