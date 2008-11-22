//
//  DBFill.h
//  DrawBerry
//
//  Created by Raphael Bost on 20/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#import <GradientPanel/GradientPanel.h>
#import <GradientPanelFramework/GPGradientPanelFramework.h>


typedef enum {
	DBNoneFillMode = 0,
	DBColorFillMode,
	DBImageFillMode,
	DBGradientFillMode
}DBFillMode;

typedef enum {
	DBStretchMode = 100,
	DBFillPathMode = 101,
	DBDrawMode = 102
}DBFillImageMode;

@class DBShape, DBTextContainer;


@interface DBFill : NSObject <NSCoding>{
	int _fillMode;
	int _imageFillMode;
	
	NSPoint _imageDrawPoint;
		
	NSColor *_fillColor;
	NSImage *_fillImage;
	NSImage *_fillCache;  
	NSImage *_maskImage;
	
	NSGradient *_gradient;
	CGFloat _grdAngle;
	GPGradientType _grdType;
	
	NSPoint _grdStartingPoint;
	CGFloat _grdStartingRadius;
	NSPoint _grdEndingPoint;
	CGFloat _grdEndingRadius;

	DBShape *_shape;
}
- (id)initWithShape:(DBShape *)shape;
- (DBShape *)shape;
- (void)setShape:(DBShape *)aValue;

- (void)fillPath:(NSBezierPath *)path;
- (void)updateFillForPath:(NSBezierPath *)path;
- (void)resetImageDrawPoint;
- (void)resizeFillFromSize:(NSSize)oldSize toSize:(NSSize)newSize;

- (int)fillMode;
- (void)setFillMode:(int)newFillMode;
- (int)imageFillMode;
- (void)setImageFillMode:(int)newImageFillMode;

- (NSColor *)fillColor;
- (void)setFillColor:(NSColor *)aValue;
- (NSImage *)fillImage;
- (void)setFillImage:(NSImage *)aValue;

- (NSGradient *)gradient;
- (void)setGradient:(NSGradient *)aValue;
- (CGFloat)gradientAngle;
- (void)setGradientAngle:(CGFloat)angle;
- (GPGradientType)gradientType;
- (void)setGradientType:(GPGradientType)type;

- (NSPoint)imageDrawPoint;
- (void)setImageDrawPoint:(NSPoint)newImageDrawPoint;
- (NSPoint)imageCenterPoint;
- (void)setImageCenterPoint:(NSPoint)newImageCenterPoint;

- (NSPoint)gradientStartingPoint;
- (void)setGradientStartingPoint:(NSPoint)newPoint;
- (NSPoint)gradientEndingPoint;
- (void)setGradientEndingPoint:(NSPoint)newPoint;
- (CGFloat)gradientStartingRadius;
- (void)setGradientStartingRadius:(CGFloat)radius;
- (CGFloat)gradientEndingRadius;
- (void)setGradientEndingRadius:(CGFloat)radius;
- (void)resetGradientPoints;

- (DBShape *)shape;
- (void)setShape:(DBShape *)aValue;

@end
