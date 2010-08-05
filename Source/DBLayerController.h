//
//  DBLayerController.h
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBLayer,DBShape;
@class DBDocument, DBDrawingView, DBUndoManager;

@interface DBLayerController : NSObject {
	NSMutableArray	*_layers;
	
	int _selectionIndex;     
	BOOL _isEditing;
	
	IBOutlet DBDocument *_document;
}

- (void)addLayer:(DBLayer *)aLayer;
- (void)insertLayers:(NSArray *)layersArray atIndexes:(NSIndexSet *)indexes;
- (DBLayer *)layerAtIndex:(unsigned int)i;
- (unsigned int)indexOfLayer:(DBLayer *)aLayer;
- (void)removeLayer:(DBLayer *)aLayer;
- (void)removeLayersAtIndexes:(NSIndexSet *)indexes;
- (NSArray *)layers;
- (void)setLayers:(NSArray *)newLayers;
- (DBLayer *)previousLayer:(DBLayer *)layer;

- (int)selectionIndex;
- (void)setSelectionIndex:(int)newSelectionIndex;
- (int)reverseSelectionIndex;
- (void)setReverseSelectionIndex:(int)newReverseSelectionIndex;
- (NSIndexSet *)reverseSelectionIndexes;
- (void)setReverseSelectionIndexes:(NSIndexSet *)aValue;
- (DBLayer *)selectedLayer;
- (void)selectLayer:(DBLayer *)layer;

- (DBDrawingView *)drawingView;
- (DBUndoManager *)documentUndoManager;
 
- (void)raiseLayerAtIndex:(unsigned int)index reversed:(BOOL)flag;
- (void)raiseAtTopLayerAtIndex:(unsigned int)index reversed:(BOOL)flag;
- (void)lowerLayerAtIndex:(unsigned int)index reversed:(BOOL)flag;
- (void)lowerAtBottomLayerAtIndex:(unsigned int)index reversed:(BOOL)flag;
- (void)moveRowsAtIndex:(int)oldIndex toIndex:(int)newIndex reversed:(BOOL)flag;

- (void)drawLayersInRect:(NSRect)rect;
- (void)drawDirectlyLayersInRect:(NSRect)rect;
- (void)needsDisplay;
- (void)updateLayersRender;
- (void)updateDependentLayers:(DBLayer *)layer;
- (void)updateLayersAndShapes;
- (void)updateShapesBounds;
- (DBShape *)hitTest:(NSPoint)point;

- (IBAction)addCILayer:(id)sender;

- (BOOL)isEditing;
- (void)setIsEditing:(BOOL)newIsEditing;
- (void)beginEditing;
- (void)endEditing;
- (DBLayer *)editingLayer;   

- (void)addImageToCurrentLayer:(NSImage *)image;
@end
