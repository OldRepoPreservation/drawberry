//
//  OHThemeFrame.m
//  OpenHUD
//
//  Created by Andy Matuschak on 1/1/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "OHThemeFrame.h"
#import "OHTitleBarButtonCell.h"
#import "NSBezierPath+Extensions.h"
#import "OHConstants.h"


@implementation OHThemeFrame

- initWithFrame:(NSRect)frame styleMask:(int)sm owner:owner
{
	[super initWithFrame:frame styleMask:sm owner:owner];
	// HUD Windows have neither miniaturization buttons nor zoom buttons.
	[[[self window] standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
	[[[self window] standardWindowButton:NSWindowZoomButton] setHidden:YES];
	
	// Set up our customized close button.
	OHTitleBarButtonCell *closeCell = [[[OHTitleBarButtonCell alloc] initImageCell:[NSImage imageNamed:@"closeButton"]] autorelease];
	[closeCell setButtonType:NSMomentaryChangeButton];
	[closeCell setBordered:NO];
	[closeCell setTarget:[self window]];
	[closeCell setAction:[[[[self window] standardWindowButton:NSWindowCloseButton] cell] action]];
	[[[self window] standardWindowButton:NSWindowCloseButton] setCell:closeCell];
	NSRect rect = [[[self window] standardWindowButton:NSWindowCloseButton] frame];
	[[[self window] standardWindowButton:NSWindowCloseButton] setFrame:rect];
	
	// I have no idea why the NSWindow doesn't do this itself, but it doesn't.
	[[self window] setShowsResizeIndicator:(sm & NSResizableWindowMask)];
	
	// We cache this gradient for optimization reasons.
	titleBarGradient = [[GCGradient gradientWithStartingColor:[NSColor colorWithDeviceWhite:0.3 alpha:1.0] endingColor:[[self contentFill] colorWithAlphaComponent:0.93]  type:kGCGradientTypeLinear angle:270] retain];
	//  colorWithAlphaComponent:1.0]
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowHUDStyleChanged:) name:OHWindowHUDStyleChangedNotificationName object:[self window]];
	
	return self;
}

- (void)dealloc
{
	[titleBarGradient release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowHUDStyleChanged:(NSNotification *)note
{
	[[self titleCell] setFont:[self titleFont]]; // Update the title cell's font--it can change with a changing HUD style.
}

// This private method is expected to return an NSPoint relative to the top-left corner of the frame; we move the button down a little.
- (NSPoint)_closeButtonOrigin
{
	return NSMakePoint(2, NSMaxY([self frame]) - 17);
}

- (int)titlebarHeight
{
	return 19;
}

- (NSRect)titlebarRect
{
	return NSMakeRect(0, NSMaxY([self bounds]) - [self titlebarHeight], NSWidth([self bounds]), [self titlebarHeight]);
}

- titleFont
{
	switch (/*HUDStyle()*/OHProStyle)
	{
		case OHIAppStyle:
			return [NSFont systemFontOfSize:11];
		case OHProStyle:
			return [NSFont boldSystemFontOfSize:10];
		default:
			return nil;
	}
}

- contentFill
{
	switch (/*HUDStyle()*/OHProStyle)
	{
		case OHIAppStyle:
			return [NSColor colorWithCalibratedWhite:0.1 alpha:0.75];
		case OHProStyle:
			return [NSColor colorWithCalibratedRed:0.12549 green:0.12549 blue:0.12549 alpha:0.95];
		default:
			return nil;
	}
}

- borderColor
{   
	return [NSColor colorWithCalibratedRed:.479182 green:.479182 blue:.479182 alpha:0.5];
}

- (float)bottomCornerRadius
{
	return 6.5;
}

- (float)topCornerRadius
{
	return 8.5;
}

// This private method handles drawing the resize indicators.
- (void)_drawResizeIndicators:(NSRect)rect
{
	if (![[self window] showsResizeIndicator]) { return; } // It calls it even if it's not supposed to! Bizarre.
	
	NSPoint resizeOrigin = NSMakePoint(NSMaxX([self frame]) - 3, 3);
	NSBezierPath *resizeGrip = [NSBezierPath bezierPath];
	[resizeGrip moveToPoint:NSMakePoint(resizeOrigin.x, resizeOrigin.y + 2)];
	[resizeGrip lineToPoint:NSMakePoint(resizeOrigin.x - 3, resizeOrigin.y)];
	[resizeGrip moveToPoint:NSMakePoint(resizeOrigin.x, resizeOrigin.y + 6)];
	[resizeGrip lineToPoint:NSMakePoint(resizeOrigin.x - 7, resizeOrigin.y)];
	[resizeGrip moveToPoint:NSMakePoint(resizeOrigin.x, resizeOrigin.y + 10)];
	[resizeGrip lineToPoint:NSMakePoint(resizeOrigin.x - 11, resizeOrigin.y)];		
	[resizeGrip setLineWidth:1.0];
	
	[[NSColor lightGrayColor] set];
	[resizeGrip stroke];	
}

- (void)drawTitleBar:(NSRect)rect
{
	NSRect frame = NSInsetRect([self frame], 0.5, -0.5); // We want to draw in the boxes of the pixel grid, not on the lines.
	NSRect titleFrame = [self titlebarRect];

	titleFrame.size.height -= 1;
	id path = [NSBezierPath bezierPathWithRoundedRect:titleFrame cornerRadius:[self topCornerRadius] inCorners:OSTopLeftCorner | OSTopRightCorner];

	[[NSColor colorWithDeviceRed:.239215 green:.239215 blue:.239215 alpha:.77647] set];

//	if(HUDStyle() == OHProStyle){
  	if(YES){
		[[self contentFill] set];
	}
	
	[path fill];
	
	// If we're the key window, draw a fancy gradient in the top half (minus the top pixel, which is for the border)
//	if (/*[[self window] isKeyWindow] && */HUDStyle() == OHProStyle)
	if(YES)
	{
		float gradientHeight = (int)([self titlebarHeight]*(1.0 / 2.0)) - 1;
		NSRect gradientRect = NSMakeRect(0, NSMaxY(frame) - gradientHeight - 1.5, NSWidth(frame)+1, gradientHeight);

		path = [NSBezierPath bezierPath];
		float radius = [self topCornerRadius];
		NSRect rect = NSInsetRect(gradientRect, radius, radius);
		
		NSPoint cornerPoint = NSMakePoint(NSMinX(gradientRect), NSMinY(gradientRect));
		
		[path appendBezierPathWithPoints:&cornerPoint count:1];

		cornerPoint = NSMakePoint(NSMaxX(gradientRect), NSMinY(gradientRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];

		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
		[path closePath];
		
		
		
		
		
		[[NSColor clearColor] set];
  
 		NSRectFill(gradientRect);

		[titleBarGradient fillPath:path];
 	}
	
	[self _drawTitleStringIn:[self titlebarRect] withColor:[NSColor whiteColor]];
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] set];
	NSRectFill(rect);
	[self drawTitleBar:rect];

	[[self contentFill] set];
	NSRect frame = NSInsetRect([self frame], 0.5, 0.5);
	NSRect contentRect = NSMakeRect(0, 0, NSWidth(frame)+1, NSMaxY(frame)+0.5 - [self titlebarHeight]);
	id path = [NSBezierPath bezierPathWithRoundedRect:contentRect cornerRadius:[self bottomCornerRadius] inCorners:OSBottomLeftCorner | OSBottomRightCorner];
	[path fill];
    
	
	// Draw the border and bevel if we're pro-styled.
//	if (HUDStyle() == OHProStyle)
	if(YES)
	{
		// We move our contentRect down by 1 px and clip to that so that the border won't draw onto the title bar.
		id borderPath = [NSBezierPath bezierPath];
		[borderPath moveToPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame) - [self topCornerRadius])];
		[borderPath lineToPoint:NSMakePoint(NSMinX(frame), [self bottomCornerRadius])];
		[borderPath appendBezierPathWithArcWithCenter:NSMakePoint([self bottomCornerRadius], [self bottomCornerRadius]) radius:[self bottomCornerRadius] startAngle:180 endAngle:270];
		[borderPath moveToPoint:NSMakePoint([self bottomCornerRadius], NSMinY(frame))];
		[borderPath lineToPoint:NSMakePoint(NSMaxX(frame) - [self bottomCornerRadius], NSMinY(frame))];
		[borderPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(frame) - [self bottomCornerRadius], [self bottomCornerRadius]) radius:[self bottomCornerRadius] startAngle:270 endAngle:360];
		[borderPath moveToPoint:NSMakePoint(NSMaxX(frame), [self bottomCornerRadius])];
		[borderPath lineToPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame) - [self topCornerRadius])];
		[borderPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(frame)- [self topCornerRadius], NSMaxY(frame) - [self topCornerRadius]) radius:[self topCornerRadius] startAngle:0.0 endAngle:90.0];
		[borderPath moveToPoint:NSMakePoint(NSMaxX(frame)- [self topCornerRadius], NSMaxY(frame))];
		[borderPath lineToPoint:NSMakePoint([self topCornerRadius], NSMaxY(frame))];
		[borderPath appendBezierPathWithArcWithCenter:NSMakePoint([self topCornerRadius], NSMaxY(frame) - [self topCornerRadius]) radius:[self topCornerRadius] startAngle: 90.0 endAngle:180.0];

		// A line width of zero ensures that the line is as thin as possible
		[borderPath setLineWidth:0];
		// Make sure the corner is as smooth as possible
		[borderPath setFlatness:0.2];
		[[self borderColor] set];
		[borderPath stroke];
//		[[self class] drawBevel:rect inFrame:[self frame] topCornerRounded:YES];
	}
}

- (NSRect)contentRectForFrameRect:(NSRect)frameRect styleMask:(unsigned int)aStyle
{
	frameRect.size.width -= 2;
	frameRect.origin.x += 1;
    frameRect.size.height -= [self titlebarHeight];
    return frameRect;
}


- (NSRect)frameRectForContentRect:(NSRect)windowContent styleMask:(unsigned int)aStyle
{
	windowContent.size.width += 2;
	windowContent.origin.x -= 1;
    windowContent.size.height += [self titlebarHeight];
    return windowContent;
}

// This private method moves the title text down 1 px from normal Aqua without overriding _drawTitleStringInRect:.
- (NSRect)_titlebarTitleRect
{
	return NSOffsetRect([super _titlebarTitleRect], 0, -1);
}

- (BOOL)preservesContentDuringLiveResize
{
	return NO;
}

@end
