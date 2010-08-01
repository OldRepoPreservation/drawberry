//
//  DBShape.h
//  DrawBerry
//
//  Created by Raphael Bost on 10/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBDrawingView.h"

#import "DBLayer.h"
#import "DBStroke.h"
#import "DBFill.h"
#import "DBShadow.h"


#define DBInsertionReplacingType 0
#define DBDeletionReplacingType 1
#define DBFragReplaceReplacingType 2

enum {
    NoKnob = 0,
    UpperLeftKnob,
    UpperMiddleKnob,
    UpperRightKnob,
    MiddleLeftKnob,
    MiddleRightKnob,
    LowerLeftKnob,
    LowerMiddleKnob,
    LowerRightKnob,
};

@interface DBShape : NSObject <NSCoding>{
	DBLayer *_layer;
	DBStroke *_stroke;
	DBFill *_fill;
	DBShadow *_shadow;
	
	NSMutableArray *_fills;
	
	NSRect _bounds;
	NSPoint _boundsCenter;
	NSSize _boundsSize;
	float _rotation;
	
	BOOL	_isEditing;
}

+ (void)drawBlueKnobAtPoint:(NSPoint)pt;
+ (void)drawOrangeKnobAtPoint:(NSPoint)pt;
+ (void)drawGreenKnobAtPoint:(NSPoint)pt;
+ (void)drawWhiteKnobAtPoint:(NSPoint)pt;
+ (void)drawGrayKnobAtPoint:(NSPoint)pt;
+ (void)drawSelectedGrayKnobAtPoint:(NSPoint)pt;

+ (NSRect)enclosingRectForShapes:(NSArray *)shapes;

- (void)drawInView:(NSView *)view rect:(NSRect)rect;
- (void)displayEditingKnobs;
- (void)displaySelectionKnobs;
- (void)drawBounds;

- (DBLayer *)layer;
- (void)setLayer:(DBLayer *)aLayer;

- (BOOL)isEditing;
- (void)setIsEditing:(BOOL)newIsEditing;

- (float)rotation;
- (void)setRotation:(float)newRotation;
- (NSPoint)rotationCenter;
- (void)rotate:(float)deltaRot;

- (DBStroke *)stroke;
- (void)setStroke:(DBStroke *)newStroke;

- (void)addFill:(DBFill *)aFill;
- (void)insertFill:(DBFill *)aFill atIndex:(unsigned int)i;
- (DBFill *)fillAtIndex:(unsigned int)i;
- (unsigned int)indexOfFill:(DBFill *)aFill;
- (void)removeFillAtIndex:(unsigned int)i;
- (NSArray *)fills;
- (void)setFills:(NSArray *)newFills;

- (NSBezierPath *)path;
- (NSRect)bounds;
- (float)zoom;

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view option:(int)option;
- (BOOL)editWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view;
- (BOOL)canEdit;

- (BOOL)hitTest:(NSPoint)point;
- (BOOL)isInRect:(NSRect)rect;
- (int)knobUnderPoint:(NSPoint)point ;
- (NSPoint)pointForKnob:(int)knob;
- (BOOL)isNaN;

- (void)moveByX:(float)deltaX byY:(float)deltaY;
- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags;
- (BOOL)changeFillImageDrawPointWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view;

- (void)updateShape;
- (void)updateFill;
- (void)applyFillsToPath:(NSBezierPath *)path;
- (void)updateBounds;
- (void)updatePath;
- (void)strokeUpdated;

- (void)flipVerticallyWithNewKnob:(int)knob;
- (void)flipHorizontalyWithNewKnob:(int)knob;

- (BOOL)replaceInView:(DBDrawingView *)view;
- (void)delete:(id)sender;
- (void)addPoint:(id)sender;

- (void)moveCorner:(int)corner toPoint:(NSPoint)point;
- (NSPoint)translationToCenterInRect:(NSRect)rect;

- (void)applyTransform:(NSAffineTransform *)at;

// fills
- (void)addFill:(DBFill *)aFill;
- (void)insertFill:(DBFill *)aFill atIndex:(unsigned int)i;
- (DBFill *)fillAtIndex:(unsigned int)i;
- (unsigned int)indexOfFill:(DBFill *)aFill;
- (void)removeFillAtIndex:(unsigned int)i;
- (void)removeFill:(DBFill *)aFill;
- (NSArray *)fills;
- (unsigned int)countOfFills;
- (void)setFills:(NSArray *)newFills;

// undo manager
- (DBUndoManager *)undoManager;
@end 

NSPoint DBMultiplyPointByFactor(NSPoint point, float factor);

BOOL DBPointIsOnKnobAtPoint(NSPoint point, NSPoint knobCenter);
BOOL DBPointIsOnKnobAtPointZoom(NSPoint point, NSPoint knobCenter, float zoom);
static double distanceBetween(NSPoint a, NSPoint b);
NSPoint resizePoint(NSPoint p, NSPoint oldOrigin, NSPoint newOrigin, float xFactor, float yFactor);
NSPoint rotatePoint(NSPoint p, NSPoint rotationCenter, float angle);