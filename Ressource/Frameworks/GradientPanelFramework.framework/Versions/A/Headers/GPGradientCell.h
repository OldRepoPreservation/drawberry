//
//  GPGradientCell.h
//  DrawBerry
//
//  Created by Raphael Bost on 25/05/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPController.h"

@class CTGradient;
@interface GPGradientCell : NSActionCell {
	NSGradient *_gradient;
	CGFloat _angle;
	GPGradientType _type;
	
	BOOL _isActive;
}
- (NSGradient *)gradient;
- (void)setGradient:(NSGradient *)aValue;
- (CGFloat)angle;
- (void)setAngle:(CGFloat)newAngle;
- (GPGradientType)gdType;
- (void)setGdType:(GPGradientType)gt;

- (BOOL)isActive;
- (void)activate:(BOOL)flag;
@end
