//
//  GPColorStopWell.h
//  GradientPanel
//
//  Created by Raphael Bost on 29/08/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GPGradientSlider.h"
extern NSString *GPSelectedColorStopDidChange;

@interface GPColorStopWell : NSControl {
	NSColor *_color;
	GPGradientSlider *_owner;
	
	BOOL _hasDragged;
	BOOL _isActive;
}

- (NSColor *)color;
- (void)setColor:(NSColor *)color;
- (GPGradientSlider *)owner;
- (void)setOwner:(GPGradientSlider *)slider;

- (void)removeStop:(id)sender;
@end
