//
//  CheckerView.h
//  GradientPanel
//
//  Created by Raphael Bost on 18/10/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CheckerView : NSView {
	NSColor *_firstColor;
	NSColor *_secondColor;
	
	NSRect* _rectList;
	int _rectNumbers;
}
- (NSColor *)firstColor;
- (void)setFirstColor:(NSColor *)color;
- (NSColor *)secondColor;
- (void)setSecondColor:(NSColor *)color;

- (void)recalculateSquares;
- (NSRect)checkedRect;
@end
