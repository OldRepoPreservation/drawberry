//
//  OHTextField.m
//  OpenHUD
//
//  Created by Andy Matuschak on 1/14/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "OHWindow.h"
#import "OHTextField.h"

@interface OHTextField (Private)
- (void)setupAppearance;
@end

@implementation OHTextField

- initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	[self setupAppearance];
	return self;
}

- initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	[self setupAppearance];
	return self;
}

- (void)drawRect:(NSRect)rect
{
	switch (/*HUDStyle()*/OHProStyle)
	{
		case OHIAppStyle:
		{
			[self setFont:[NSFont systemFontOfSize:11]];
			break;
		}
		case OHProStyle:
		{
			[self setFont:[NSFont boldSystemFontOfSize:10]];
			break;
		}
	}
	[super drawRect:rect];
}

- (void)setupAppearance
{
	[self setTextColor:[NSColor whiteColor]];
	[self setEditable:NO];
	[self setBezeled:NO];
	[self setDrawsBackground:NO];
}

@end