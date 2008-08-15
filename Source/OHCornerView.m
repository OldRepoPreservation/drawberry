//
//  OHCornerView.m
//  OpenHUD
//
//  Created by Jeff Ganyard on 4/17/06.
//

#import "OHCornerView.h"
#import "CTGradient2.h"

@implementation OHCornerView

- (void)drawRect:(NSRect)aRect 
{
/*
	NSRect divide = NSMakeRect (aRect.origin.x, aRect.origin.y, aRect.size.width, 1);
	NSRect rect = aRect;
	rect.origin.y += 1;
	rect.size.height -= 1;
	
	[[NSColor blackColor] set];
	NSRectFill (divide);
	//rect = [GSDrawFunctions drawDarkButton: rect :aRect];
	[[NSColor controlShadowColor] set];
	NSRectFill (rect);
*/
	[[NSColor colorWithCalibratedWhite:.5 alpha:.8 ] set];
	NSRectFill(aRect);
	CTGradient2 *bgGradient = [CTGradient2 gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:.5 alpha:.8] endingColor:[[NSColor blackColor] colorWithAlphaComponent:.8]];
	[bgGradient fillRect:aRect angle:270];
}

@end
