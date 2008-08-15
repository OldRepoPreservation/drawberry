//
//  OHWindow.m
//  OpenHUD
//
//  Created by Andy Matuschak on 1/1/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "OHWindow.h"
#import "OHThemeFrame.h"

const int OHHUDWindowMask = 2 << 23;

@interface NSWindow (Private)
+ (Class)frameViewClassForStyleMask:(unsigned int)mask;
@end

@interface OHWindow (Private)
- (void)setupAppearance;
@end

@implementation OHWindow

// This private method is expected to return an appropriate frame view class for a given style mask.
// We override it to watch for the HUD windows mask; if it's there, we use the OHThemeFrame.
+ (Class)frameViewClassForStyleMask:(unsigned int)styleMask
{
	if (styleMask & OHHUDWindowMask)
		return [OHThemeFrame class];
	return [super frameViewClassForStyleMask:styleMask];
}

- initWithContentRect:(NSRect)rect styleMask:(int)mask backing:(NSBackingStoreType)backing defer:(BOOL)flag
{
	// Is the automatic adding of the OHHUDWindowMask expected behavior? I -think- it is.
	[super initWithContentRect:rect styleMask:mask | OHHUDWindowMask backing:backing defer:flag];
	[self setupAppearance];
	return self;
}

- initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	[self setupAppearance];
	return self;
}

- (void)setupAppearance
{
	[self setOpaque:NO];
	[self setMovableByWindowBackground:YES];
	[self setLevel:NSFloatingWindowLevel];
	HUDStyle = OHProStyle;
}

- (OHStyle)HUDStyle
{
	return HUDStyle;
}

- (void)setHUDStyle:(OHStyle)style
{
	HUDStyle = style;
	[[NSNotificationCenter defaultCenter] postNotificationName:OHWindowHUDStyleChangedNotificationName object:self];
	[self display];
}

@end
