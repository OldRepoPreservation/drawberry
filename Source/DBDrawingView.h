//
//  DBDrawingView.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DBDocument; 
@class DBShape;
@class EMErrorManager;
@class DBMagnifyingView;
@class DBContextualDataSourceController;
@class DBLayerController;

@interface DBDrawingView : NSView {
	NSRect _canevasRect;
	
	NSColor *_backgroundColor;
	NSColor *_gridColor;
	NSColor *_canevasColor;
	
	BOOL _showGrid;
	BOOL _showRulers;  
	
	BOOL _snapToGrid;
	
	float _gridSpacing;
	int _gridTickCount;
	
	float _zoom;
	
	IBOutlet DBDocument *_document;
	
	IBOutlet DBContextualDataSourceController *_dataSourceController;
	
	DBShape *_editingShape;
	NSMutableArray *_selectedShapes;
	
	NSRect _selectionRect;
	NSSet *_selectionRectShapes; 

	EMErrorManager *_eManager;
	
	BOOL _isExporting;
	
	NSRulerView *_horizontalRuler;
	NSRulerView *_verticalRuler;
	NSRulerMarker *_mouseHorizRulerMarker;
	NSRulerMarker *_leftHorizRulerMarker;
	NSRulerMarker *_rightHorizRulerMarker;
	NSRulerMarker *_mouseVertRulerMarker;
	NSRulerMarker *_upVertRulerMarker;
	NSRulerMarker *_downVertRulerMarker;
	
	IBOutlet DBMagnifyingView *_magnifyingGlass;
	
	int _draggedShapesCount;
}

#pragma mark Accessors

- (BOOL)isExporting;
- (void)setExporting:(BOOL)newIsExporting;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)aValue;
- (NSColor *)gridColor;
- (void)setGridColor:(NSColor *)aValue;
- (NSColor *)canevasColor;
- (void)setCanevasColor:(NSColor *)aValue;
- (NSSize)canevasSize;
- (NSSize)zoomedCanevasSize;
- (void)setCanevasSize:(NSSize)newCanevasSize;
- (BOOL)showGrid;
- (void)setShowGrid:(BOOL)newShowGrid;
- (float)gridSpacing;
- (void)setGridSpacing:(float)newGridSpacing;
- (int)gridTickCount;
- (void)setGridTickCount:(int)newGridTickCount;
- (BOOL)showRulers;
- (void)setShowRulers:(BOOL)newShowRulers;
- (float)canevasWidth;
- (void)setCanevasWidth:(float)newCanevasWidth;
- (float)canevasHeight;
- (void)setCanevasHeight:(float)newCanevasHeight;
- (float)zoom;
- (void)setZoom:(float)newZoom;
- (float)zoomExponent;
- (void)setZoomExponent:(float)newZoomExponent;
- (float)zoomPercentage;
- (void)setZoomPercentage:(float)newZoomPercentage;
- (BOOL)snapToGrid;
- (void)setSnapToGrid:(BOOL)newSnapToGrid;
- (DBLayerController *)layerController;
#pragma mark Canevas Origin & Coordinates changes

- (void)updateCanevasOrigin; 
- (void)updateFrameOrigin;
- (NSPoint)canevasOrigin;

- (NSPoint)canevasCoordinatesFromViewCoordinates:(NSPoint)point;
- (NSPoint)viewCoordinatesFromCanevasCoordinates:(NSPoint)point;  
- (NSPoint)pointSnapedToGrid:(NSPoint)point;
- (NSPoint)pointSnapedToGridInCanvas:(NSPoint)point;

- (NSAffineTransform *)appliedTransformation;
#pragma mark Shape creation, selection and modification
- (void)createShapeOfClass:(Class)theClass withEvent:(NSEvent *)theEvent;
- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent;
- (void)moveSelectedShapesWithEvent:(NSEvent *)theEvent ;
- (void)selectRectWithEvent:(NSEvent *)theEvent;
- (void)resizeSelectedShapeWithEvent:(NSEvent *)theEvent knob:(int)knob;
- (void)rotateSelectedShapeWithEvent:(NSEvent *)theEvent;

- (void)startEditingShape:(DBShape *)shape;
- (void)stopEditingShape;
- (DBShape *)editingShape;

#pragma mark Selected Shapes

- (void)selectShape:(DBShape *)shape;
- (void)deselectShape:(DBShape *)shape;
- (void)toggleSelectShape:(DBShape *)shape;
- (void)deselectAllShapes;
- (BOOL)shapeIsSelected:(DBShape *)shape;
- (DBShape *)selectedShape;
- (NSArray *)selectedShapes;
- (NSArray *)selectedShapesLayers;

- (void)duplicateSelectedShapes;

#pragma mark Search Shapes

- (NSSet *)shapesInRect:(NSRect)rect;

#pragma mark Rulers

- (void)moveMouseRulerMarkerWithEvent:(NSEvent *)theEvent;
- (void)moveHorizMouseRulerMarkerToLocation:(float)loc;
- (void)moveVertMouseRulerMarkerToLocation:(float)loc;
- (void)setRightMarkerLocation:(float)loc;
- (void)setLeftMarkerLocation:(float)loc;
- (void)setUpMarkerLocation:(float)loc;
- (void)setDownMarkerLocation:(float)loc;
- (NSPoint)rulerLocationWithPoint:(NSPoint)point;
- (void)updateRulerUnits;                    

#pragma mark Errors
- (EMErrorManager *)errorManager;
@end

NSRect DBRectWithPoints(NSPoint firstPoint, NSPoint secondPoint);
float DBAngleBetweenPoints(NSPoint center, NSPoint point1, NSPoint point2);