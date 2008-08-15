//
//  OHTableHeaderCell.m
//  OpenHUD
//
//  Created by Jeff Ganyard on 4/17/06.
//

#import "OHTableHeaderCell.h"
#import "CTGradient2.h"

@implementation OHTableHeaderCell

- (id)initTextCell:(NSString *)text
{
    if (self = [super initTextCell:text]) {
        if (text == nil || [text isEqualToString:@""]) {
            [self setTitle:@"  "];
        }
        return self;
    }
    return nil;
}


- (void)drawWithFrame:(NSRect)inFrame inView:(NSView*)inView
{
//	CTGradient2 *bgGradient = [CTGradient2 gradientWithBeginningColor:[NSColor colorWithDeviceRed:.372549 green:.372549 blue:.372549 alpha:.75] endingColor:[NSColor colorWithDeviceRed:.290196 green:.290196 blue:.290196 alpha:.75]];
	[[NSColor colorWithCalibratedWhite:.5 alpha:.8 ] set];
	NSRectFill(inFrame);
	CTGradient2 *bgGradient = [CTGradient2 gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:.5 alpha:.8] endingColor:[[NSColor blackColor] colorWithAlphaComponent:.8]];
	[bgGradient fillRect:inFrame angle:90];
		
	/* portions based on Matt Gemmel's iTableColumnHeader */
	/* Draw white text centered, but offset down-left. */
	float offset = 0.5;
	
	NSMutableDictionary *attrs = [[NSMutableDictionary dictionaryWithDictionary: [[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]] mutableCopy];

    [attrs setValue:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] 
             forKey:@"NSColor"];
	NSRect centeredRect = inFrame;
	centeredRect.size = [[self stringValue] sizeWithAttributes:attrs];
	centeredRect.origin.x += ((inFrame.size.width - centeredRect.size.width) / 2.0) - offset;
	centeredRect.origin.y = ((inFrame.size.height - centeredRect.size.height) / 2.0) + offset;
	[[self stringValue] drawInRect:centeredRect withAttributes:attrs];

	/* Draw black text centered. */
	[attrs setValue:[NSColor colorWithCalibratedWhite:0.9 alpha:0.7] forKey:@"NSColor"];
	centeredRect.origin.x += offset;
	centeredRect.origin.y -= offset;
	[[self stringValue] drawInRect:centeredRect withAttributes:attrs];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)inFrame inView:(NSView *)inView
{
//	NSLog(@"highlight");
	[[NSColor colorWithCalibratedWhite:.3 alpha:.8 ] set];
	NSRectFill(inFrame);
	CTGradient2 *bgGradient = [CTGradient2 gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:.8 alpha:.8] endingColor:[[NSColor blackColor] colorWithAlphaComponent:.8]];
	[bgGradient fillRect:inFrame angle:90];

	/* Draw white text centered, but offset down-left. */
	float offset = 0.5;
	
	NSMutableDictionary *attrs = [[NSMutableDictionary dictionaryWithDictionary: [[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]] mutableCopy];
	
    [attrs setValue:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] 
             forKey:@"NSColor"];
	NSRect centeredRect = inFrame;
	centeredRect.size = [[self stringValue] sizeWithAttributes:attrs];
	centeredRect.origin.x += ((inFrame.size.width - centeredRect.size.width) / 2.0) - offset;
	centeredRect.origin.y = ((inFrame.size.height - centeredRect.size.height) / 2.0) + offset;
	[[self stringValue] drawInRect:centeredRect withAttributes:attrs];
	
	/* Draw black text centered. */
	[attrs setValue:[NSColor colorWithCalibratedWhite:0.9 alpha:0.7] forKey:@"NSColor"];
	centeredRect.origin.x += offset;
	centeredRect.origin.y -= offset;
	[[self stringValue] drawInRect:centeredRect withAttributes:attrs];
}

@end
