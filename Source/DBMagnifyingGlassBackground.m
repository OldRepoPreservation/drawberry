//
//  DBMagnifyingGlassBackground.m
//  DrawBerry
//
//  Created by Raphael Bost on 02/05/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import "DBMagnifyingGlassBackground.h"

@implementation DBMagnifyingGlassBackground

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	
	NSPoint center;
	float radius;
   	
	center = NSMakePoint([self frame].size.width/2-1.0, ([self frame].size.height)/2-1.0); 
	radius = MIN([self frame].size.width,[self frame].size.height)/2-0.5;
	    
	NSBezierPath *circle = [[NSBezierPath alloc] init];
	[circle appendBezierPathWithArcWithCenter:center radius:radius-10.0 startAngle:0 endAngle:360];
	
	NSBezierPath *back = [[NSBezierPath alloc] init];
	[back appendBezierPathWithRect:[self frame]];
	[back appendBezierPath:circle];
	[back setWindingRule:NSEvenOddWindingRule];
	
	
	[NSGraphicsContext saveGraphicsState];   
	NSBezierPath *background = [[NSBezierPath alloc] init];
	
	[background appendBezierPathWithArcWithCenter:center radius:radius startAngle:90 endAngle:0 clockwise:NO];
	[background lineToPoint:NSMakePoint(center.x+radius,center.y + radius-7.0)];
	[background appendBezierPathWithArcWithCenter:NSMakePoint(center.x+radius-7.0,center.y + radius - 7.0) radius:7.0 startAngle:0 endAngle:90 clockwise:NO];
	[background lineToPoint:NSMakePoint(center.x,center.y + radius)];
	[background closePath];
	
	[[NSColor colorWithCalibratedRed:0.12549 green:0.12549 blue:0.12549 alpha:0.95] set];
	[background fill];
	[[NSColor colorWithCalibratedRed:.479182 green:.479182 blue:.479182 alpha:0.5] set];
	[background stroke];
	
	[NSGraphicsContext restoreGraphicsState];

	[circle release];
	[back release];
}

- (BOOL)isFlipped {
	return YES;
}
@end
