//
//  OHScroller.m
//  OpenHUD
//
//  Created by Andy Matuschak on 11/6/05.
//  Copyright 2005 Andy Matuschak. All rights reserved.
//

#import "OHScroller.h"
#import "CTGradient2.h"

@implementation OHScroller

// This method is undocumented but seems to be what is called for arrow drawing in 10.4; not the documented drawArrow:highlight: method, which was never executed in my tests.

- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)part
{
    // Get bounds
    NSRect  bounds;
    bounds = [self bounds];

    // Check flip
    BOOL    flipped;
    flipped = [self isFlipped];

    static NSColor* _dividerColor = nil;
    if (!_dividerColor) {
        _dividerColor = [[NSColor colorWithCalibratedWhite:0.522 alpha:1.0f] retain];
    }

    // Draw back
    NSRect  rect, imageRect;
    if (arrow == NSScrollerIncrementArrow) {
        // Down arrow
        NSImage*    image;
        if (part == 0) {
            image = [NSImage imageNamed:@"blkScrollerBackVBDownSelected"];
//            image = [NSImage frameworkImageNamed:@"blkScrollerBackVBDownSelected"];
        }
        else {
            image = [NSImage imageNamed:@"blkScrollerBackVBDown"];
//            image = [NSImage frameworkImageNamed:@"blkScrollerBackVBDown"];
        }

        rect.origin.x = 0;
        rect.origin.y = bounds.size.height - [image size].height;
        rect.size = [image size];
        imageRect.origin = NSZeroPoint;
        imageRect.size = [image size];
        if ([image isFlipped] != flipped) {
            [image setFlipped:flipped];
        }
        [image drawInRect:rect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0f];

        // Divider
        [_dividerColor set];
        NSFrameRect(NSMakeRect(0, rect.origin.y - 1, bounds.size.width, 1));

        // Up arrow
        if (part == 1) {
            image = [NSImage imageNamed:@"blkScrollerBackVBUpSelected"];
        }
        else {
            image = [NSImage imageNamed:@"blkScrollerBackVBUp"];
        }

        rect.origin.y -= [image size].height + 1;
        rect.size = [image size];
        imageRect.origin = NSZeroPoint;
        imageRect.size = [image size];
        if ([image isFlipped] != flipped) {
            [image setFlipped:flipped];
        }
        [image drawInRect:rect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0f];
    }
    else if (arrow == NSScrollerDecrementArrow) {
           NSImage *image = [NSImage imageNamed:@"blkScrollerBackVT"];
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size = [image size];
        imageRect.origin = NSZeroPoint;
        imageRect.size = [image size];
        if ([image isFlipped] != flipped) {
            [image setFlipped:flipped];
        }
        [image drawInRect:rect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0f];
    }
}

// This method, while in the documentation and the header, never seems to get called. At least in 10.4. Instead, drawArrow:highlightPart: (an undocumented method) is called. So in case this method was used in previous versions of the OS, I'm forwarding calls from this (seemingly useless) method to the one that actually does things.
- (void)drawArrow:(int)arrow highlight:(BOOL)highlight
{
	[self drawArrow:arrow highlightPart:highlight ? 0 : -1];
}

- (void)drawKnob
{
	NSImage *knobCap = [NSImage imageNamed:@"scroller_knob_fill_cap"];
	NSImage *knobFill = [NSImage imageNamed:@"scroller_knob_fill"];
	NSRect fillRect = NSInsetRect([self rectForPart:NSScrollerKnob], 0, [knobCap size].height);
	[knobFill drawInRect:fillRect fromRect:(NSRect){NSZeroPoint, [knobFill size]} operation:NSCompositeSourceAtop fraction:1];
	[knobCap setFlipped:NO];
	[knobCap drawAtPoint:NSMakePoint(0, NSMaxY(fillRect)) fromRect:(NSRect){NSZeroPoint, [knobCap size]} operation:NSCompositeSourceAtop fraction:1];
	[knobCap setFlipped:YES];
	[knobCap drawAtPoint:NSMakePoint(0, NSMinY([self rectForPart:NSScrollerKnob])) fromRect:(NSRect){NSZeroPoint, [knobCap size]} operation:NSCompositeSourceAtop fraction:1];
}

- (BOOL)isOpaque
{
	return NO;
}

// This method draws the body of the scroller; the area behind the knob. It's undocumented and not particularly clear from the name alone.
- (void)drawKnobSlotInRect:(NSRect)rect highlight:(BOOL)highlight
{
	CTGradient2 *slotGradient = [CTGradient2 gradientWithBeginningColor:[NSColor colorWithCalibratedRed:.02 green:.02 blue:.02 alpha:.85] endingColor:[NSColor colorWithCalibratedWhite:0 alpha:.16]];
    [slotGradient fillRect:rect angle:0];
	[[NSColor greenColor] set];

	[[NSColor colorWithCalibratedRed:.24 green:.24 blue:.24 alpha:0.85] set];

	NSRectFill(NSMakeRect(NSMaxX(rect)-1, NSMinY(rect), 1, NSHeight(rect)));
}

@end
