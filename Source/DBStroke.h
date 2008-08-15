//
//  DBStroke.h
//  DrawBerry
//
//  Created by Raphael Bost on 19/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBShape;

typedef enum {
	DBColorStrokeMode = 0,
	DBImagePatternStrokeMode,
	DBNoStrokeMode
}DBStrokeMode;

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

@interface DBStroke : NSObject {
	BOOL _stroke;
	
	int _strokeMode;
	
	float _lineWidth;
	int _lineJoinStyle;
	int _lineCapStyle;

	int _arrowStyle;
	int _dashStyle;
	
	NSColor *_strokeColor;
	NSImage	*_patternImage;  
	
	DBShape *_shape;
	
	BOOL _showStartArrow;
	BOOL _showEndArrow;
	DBArrowStyle _startArrowStyle;
	DBArrowStyle _endArrowStyle;
	NSColor *_startArrowFillColor;
	NSColor *_endArrowFillColor;
	BOOL _strokeStartArrow;
	BOOL _strokeEndArrow;
	BOOL _fillStartArrow;
	BOOL _fillEndArrow;
	
	NSMutableAttributedString *_text;
	NSBezierPath *_textPath;
	float _textOffset;
	BOOL _flipText;
	int _textPosition;
	NSTextAlignment _textAlignment;
}
- (id)initWithShape:(DBShape *)shape;
- (DBShape *)shape;
- (void)setShape:(DBShape *)aValue;

- (int)strokeMode;
- (void)setStrokeMode:(int)newStrokeMode;
- (BOOL)needsColor;
- (BOOL)needsPatternImage;

- (BOOL)stroke;
- (void)setStroke:(BOOL)newStroke;

- (float)lineWidth;
- (void)setLineWidth:(float)newLineWidth;
- (int)lineJoinStyle;
- (void)setLineJoinStyle:(int)newLineJoinStyle;
- (int)lineCapStyle;
- (void)setLineCapStyle:(int)newLineCapStyle;
- (int)arrowStyle;
- (void)setArrowStyle:(int)newArrowStyle;
- (int)dashStyle;
- (void)setDashStyle:(int)newDashStyle;
- (NSColor *)strokeColor;
- (void)setStrokeColor:(NSColor *)aValue;
- (NSImage *)patternImage;
- (void)setPatternImage:(NSImage *)aValue;

// arrows
- (BOOL)showStartArrow;
- (void)setShowStartArrow:(BOOL)newShowStartArrow;
- (BOOL)showEndArrow;
- (void)setShowEndArrow:(BOOL)newShowEndArrow;
- (DBArrowStyle)startArrowStyle;
- (void)setStartArrowStyle:(DBArrowStyle)newstartArrowStyle;
- (DBArrowStyle)endArrowStyle;
- (void)setEndArrowStyle:(DBArrowStyle)newendArrowStyle;
- (NSColor *)startArrowFillColor;
- (void)setStartArrowFillColor:(NSColor *)aValue;
- (NSColor *)endArrowFillColor;
- (void)setEndArrowFillColor:(NSColor *)aValue;         
- (BOOL)strokeStartArrow;
- (void)setStrokeStartArrow:(BOOL)newStrokeStartArrow;
- (BOOL)strokeEndArrow;
- (void)setStrokeEndArrow:(BOOL)newStrokeEndArrow;
- (BOOL)fillStartArrow;
- (void)setFillStartArrow:(BOOL)newFillStartArrow;
- (BOOL)fillEndArrow;
- (void)setFillEndArrow:(BOOL)newFillEndArrow;

- (DBShape *)shape;
- (void)setShape:(DBShape *)aValue;

// text
- (NSAttributedString *)text;
- (void)setText:(NSAttributedString *)aValue;
- (float)textOffset;
- (void)setTextOffset:(float)newTextOffset;
- (BOOL)flipText;
- (void)setFlipText:(BOOL)newFlipText;
- (int)textPosition;
- (void)setTextPosition:(int)newTextPosition;
// stroke
- (void)updateStrokeForPath:(NSBezierPath *)drawPath;
- (void)strokePath:(NSBezierPath *)drawPath;
@end
