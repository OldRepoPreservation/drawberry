//
//  DBScrollView.m
//  DrawBerry
//
//  Created by Raphael Bost on 13/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBScrollView.h"


@implementation DBScrollView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.   	
    }
    return self;
}

- (void)awakeFromNib
{
	[_accessoryView retain];
	[_accessoryView removeFromSuperviewWithoutNeedingDisplay];
	[self addSubview:_accessoryView positioned:NSWindowAbove relativeTo:nil];
}

- (void)tile
{
	[super tile];
	
	NSScroller *horizontalScroller;
	NSRect scrollerFrame;
	float accViewWidth;
	horizontalScroller = [self horizontalScroller];
	scrollerFrame = [horizontalScroller frame];

	[_accessoryView setFrameOrigin:scrollerFrame.origin];     
	accViewWidth = [_accessoryView frame].size.width;
	scrollerFrame.origin.x += accViewWidth;
	scrollerFrame.size.width -= accViewWidth;

	[horizontalScroller setFrame:scrollerFrame];
} 
@end
