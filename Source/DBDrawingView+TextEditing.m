//
//  DBDrawingView+TextEditing.m
//  DrawBerry
//
//  Created by Raphael Bost on 27/02/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBDrawingView+TextEditing.h"


@implementation DBDrawingView (TextEditing)
- (void)addTextView:(NSTextView *)textView
{
	[self addSubview:textView];
	[[self window] makeFirstResponder:textView];
}

- (void)removeTextView:(NSTextView *)textView
{
	[textView setNeedsDisplay:YES];
	[textView removeFromSuperview]; 
}
@end
