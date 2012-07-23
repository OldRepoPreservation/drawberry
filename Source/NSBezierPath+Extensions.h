//
//  NSBezierPath+Extensions.h
//  DrawBerry
//
//  Created by Raphael Bost on 27/05/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef DB_ARROWSTYLE
#define DB_ARROWSTYLE
typedef enum {
	DBFullArrowStyle = 0,
	DBCircleStyle,
	DBOpenArrowStyle,
	DBDiamondStyle,
	DBPointYArrowStyle
}DBArrowStyle;
#endif

typedef enum _OSCornerTypes
{
	OSTopLeftCorner = 1,
	OSBottomLeftCorner = 2,
	OSTopRightCorner = 4,
	OSBottomRightCorner = 8
} OSCornerType;

typedef struct {
	float arrowLength;
	float arrowAngle;
} DBArrowOptions;

@interface NSBezierPath (DBExtensions)
- (NSBezierPath *)startArrowWithType:(DBArrowStyle)type options:(DBArrowOptions)options;
- (NSBezierPath *)endArrowWithType:(DBArrowStyle)type options:(DBArrowOptions)options;
@end

@interface NSBezierPath (RoundedRectangle)
+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect)aRect cornerRadius: (float)radius;
+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect)aRect cornerRadius: (float)radius inCorners:(OSCornerType)corners;
@end

@interface  NSBezierPath (Text)
- (void)				drawTextOnPath:(NSAttributedString*) str yOffset:(float) dy;
- (void)				drawStringOnPath:(NSString*) str;
- (void)				drawStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs;

- (NSBezierPath*)       bezierPathWithTextOnPath:(NSAttributedString*) str locationOffset:(float)dloc yOffset:(float) dy;
- (NSBezierPath*)		bezierPathWithStringOnPath:(NSString*) str;
- (NSBezierPath*)		bezierPathWithStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs;
@end

DBArrowOptions DBMakeArrowOptions (float arrowLength, float arrowAngle);
DBArrowOptions DBDefaultArrowOptions ();