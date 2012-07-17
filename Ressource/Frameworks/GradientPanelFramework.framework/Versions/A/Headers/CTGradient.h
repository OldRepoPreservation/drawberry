//
//  CTGradient.h
//
//  Created by Chad Weider on 2/14/07.
//  Writtin by Chad Weider.
//
//  Released into public domain on 4/10/08.
//  
//  Version: 1.8

#import <Cocoa/Cocoa.h>

typedef enum _GPGradientType {
	GPLinearType = 0,
	GPRadialType
}	GPGradientType;

typedef struct _CTGradientElement 
	{
	CGFloat red, green, blue, alpha;
	CGFloat position;
	
	struct _CTGradientElement *nextElement;
	} CTGradientElement;

typedef enum  _CTBlendingMode
	{
	CTLinearBlendingMode,
	CTChromaticBlendingMode,
	CTInverseChromaticBlendingMode
	} CTGradientBlendingMode;


@interface CTGradient : NSObject <NSCopying, NSCoding>
	{
	CTGradientElement* elementList;
	CTGradientBlendingMode blendingMode;
	
	CGFunctionRef gradientFunction;
	}

+ (id)gradientWithBeginningColor:(NSColor *)begin endingColor:(NSColor *)end;

+ (id)aquaSelectedGradient;
+ (id)aquaNormalGradient;
+ (id)aquaPressedGradient;

+ (id)unifiedSelectedGradient;
+ (id)unifiedNormalGradient;
+ (id)unifiedPressedGradient;
+ (id)unifiedDarkGradient;

+ (id)sourceListSelectedGradient;
+ (id)sourceListUnselectedGradient;

+ (id)rainbowGradient;
+ (id)hydrogenSpectrumGradient;

- (CTGradient *)gradientWithAlphaComponent:(CGFloat)alpha;

- (CTGradient *)addColorStop:(NSColor *)color atPosition:(CGFloat)position;	//positions given relative to [0,1]
- (CTGradient *)removeColorStopAtIndex:(NSUInteger)index;
- (CTGradient *)removeColorStopAtPosition:(CGFloat)position;

- (CTGradientBlendingMode)blendingMode;
- (NSColor *)colorStopAtIndex:(NSUInteger)index;
- (NSColor *)colorAtPosition:(CGFloat)position;


- (void)drawSwatchInRect:(NSRect)rect;
- (void)fillRect:(NSRect)rect angle:(CGFloat)angle;					//fills rect with axial gradient
																	//	angle in degrees
- (void)radialFillRect:(NSRect)rect;								//fills rect with radial gradient
																	//  gradient from center outwards
- (void)fillBezierPath:(NSBezierPath *)path angle:(CGFloat)angle;
- (void)radialFillBezierPath:(NSBezierPath *)path;

@end

@interface CTGradient (Private)
- (void)_commonInit;
- (void)setBlendingMode:(CTGradientBlendingMode)mode;
- (void)addElement:(CTGradientElement*)newElement;

- (CTGradientElement *)elementAtIndex:(NSUInteger)index;
- (int)numberOfElements;
- (CTGradientElement)removeElementAtIndex:(NSUInteger)index;
- (CTGradientElement)removeElementAtPosition:(CGFloat)position;
- (void)setPosition:(float)loc forElementAtIndex:(NSInteger)index;

- (int)elementIndexForPosition:(CGFloat)position;
@end

@interface CTGradient (BGHUDAppKit)
+ (id)normalGradient;
+ (id)highlightGradient;
@end

@interface CTGradient (Cocoa_Gradient)
+ (id)gradientWithGradient:(NSGradient *)grd;
- (id)initWithGradient:(NSGradient *)grd;
- (NSGradient *)convertGradient;
@end

