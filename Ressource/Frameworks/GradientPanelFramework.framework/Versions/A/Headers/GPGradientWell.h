//
//  GPGradientWell.h
//  GradientPanel
//
//  Created by Raphael Bost on 25/05/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CTGradient.h"

@interface GPGradientWell : NSControl {

}
- (NSGradient *)gradient;
- (void)setGradient:(NSGradient *)newGradient;
- (CGFloat)gradientAngle;
- (void)setGradientAngle:(CGFloat)angle;
- (GPGradientType)gradientType;
- (void)setGradientType:(GPGradientType)type;

- (BOOL)isActive;
- (void)activate:(BOOL)flag;
- (void)deactivate;
@end
