//
//  GPGradientSlider.h
//  GradientPanel
//
//  Created by Raphael Bost on 27/08/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CheckerView.h"

@class GPController;
@class GPColorStopWell;

@interface GPGradientSlider : CheckerView {
	IBOutlet GPController *_controller;
	
	NSMutableArray *_colorStops;
	
	NSPoint _menuClickLocation;
}
- (void)updateGradientLine;
- (void)updateLocationForStop:(GPColorStopWell *)well deltaPos:(float)deltaPos;
- (void)setColor:(NSColor *)color forStop:(GPColorStopWell *)well;

- (void)addColorStopAtLocation:(CGFloat)location;
- (void)removeStop:(GPColorStopWell *)stop;

- (IBAction)addStop:(id)sender;
- (IBAction)copyGradient:(id)sender;
@end
