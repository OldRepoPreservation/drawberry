//
//  GPGradientView.h
//  GradientPanel
//
//  Created by Raphael Bost on 27/08/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CheckerView.h"

@class GPController;
@class CTGradient;

@interface GPGradientView : CheckerView {
	IBOutlet GPController *_controller;
}

@property (retain)  CTGradient *gradient;
@property CGFloat angle;

- (CTGradient *)gradient;
- (void)setGradient:(CTGradient *)grd;
- (CGFloat)angle;
- (void)setAngle:(CGFloat)newAngle;
@end
