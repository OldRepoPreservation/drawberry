//
//  DBShadowControl.h
//  ShadowControl
//
//  Created by Raphael Bost on 22/08/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBShadowControl : NSControl {
	NSShadow *_shadow;
	int _trackingTag;
	
	id _target;
	SEL _action;
}
- (NSPoint)centerPoint;
- (NSPoint)offsetPoint;

- (float)shadowOffsetWidth;
- (void)setShadowOffsetWidth:(float)newShadowOffsetWidth;
- (float)shadowOffsetHeight;
- (void)setShadowOffsetHeight:(float)newShadowOffsetHeight;
- (float)shadowBlurRadius;
- (void)setShadowBlurRadius:(float)newShadowBlurRadius;
- (NSColor *)shadowColor;
- (void)setShadowColor:(NSColor *)aColor;
@end
