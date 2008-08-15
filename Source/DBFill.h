//
//  DBFill.h
//  DrawBerry
//
//  Created by Raphael Bost on 20/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GradientPanel/GradientPanel.h>


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
	GCGradient *_gradient;
	
//	NSTextStorage *_text;
//	DBTextContainer *_textContainer;
//	NSMutableAttributedString *_text;
//    int _vertPos;
//	NSTextAlignment _textAlignment;
	
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

- (GCGradient *)gradient;
- (void)setGradient:(GCGradient *)aValue;

//- (NSAttributedString *)text;
//- (void)setText:(NSAttributedString *)newText;

- (NSPoint)imageDrawPoint;
- (void)setImageDrawPoint:(NSPoint)newImageDrawPoint;
- (NSPoint)imageCenterPoint;
- (void)setImageCenterPoint:(NSPoint)newImageCenterPoint;

- (DBShape *)shape;
- (void)setShape:(DBShape *)aValue;

@end
