//
//  GPGradientPanel.h
//  GradientPanel
//
//  Created by Raphael Bost on 31/08/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CTGradient.h"

@class GPController;
@class CTGradient;

@interface GPGradientPanel : NSWindowController {
	IBOutlet id _delegate;
	
	IBOutlet GPController *_gradientController;
	
}
+ (id)sharedGradientPanel;
- (id)delegate;
- (void)setDelegate:(id)del;

- (NSGradient *)gradient;
- (void)setGradient:(NSGradient *)grd;
- (CGFloat)angle;
- (void)setAngle:(CGFloat)newAngle;
- (GPGradientType)gradientType;
- (void)setGradientType:(GPGradientType)gt;
@end

@interface NSObject(GPGradientPanelResponderMethod)
- (void)changeGradient:(id)sender;
@end