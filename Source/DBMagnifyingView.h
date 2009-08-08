//
//  DBMagnifyingView.h
//  DrawBerry
//
//  Created by Raphael Bost on 01/09/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _DBMagnifyingType{
	DBVectorialMagnifyingType = 100,
	DBPixellisationMagnifyingType,
}DBMagnifyingType;

@interface DBMagnifyingView : NSView {
	IBOutlet NSView *_source;
	
	IBOutlet NSTextField *_zoomField;
	
	NSPoint _magnifyingPoint;
	float _zoom;
	BOOL _isDrawing;
	BOOL _isResizing;
	
	
	float _startAngle, _endAngle;
	
	BOOL _isHighlighted;
	
	float _floatValue;
@private
	BOOL _isDragging;
}

- (NSView *)source;
- (void)setSource:(NSView *)newSource;
- (NSPoint)magnifyingPoint;
- (void)setMagnifyingPoint:(NSPoint)newMagnifyingPoint;
- (float)zoom;
- (void)setZoom:(float)newZoom;
                                         
- (BOOL)isDrawingSource;
- (NSRect)sourceZoomedRect;

- (void)correctWindowPlace;
- (void)correctMagPoint;

- (IBAction)takeZoomValueFrom:(id)sender;
- (IBAction)update:(id)sender;




- (void)drawSlider;
- (void)drawKnobAtPoint:(NSPoint)p;
- (BOOL)isHighlighted;
- (float)sliderRadius;
- (NSPoint)centerPoint;

- (float)floatValue;
- (void)setFloatValue:(float)f;
- (float)minValue;
- (float)maxValue;
- (BOOL)isEnabled;

@end
