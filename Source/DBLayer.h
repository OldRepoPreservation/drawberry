//
//  DBLayer.h
//  DrawBerry
//
//  Created by Raphael Bost on 10/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBLayerController.h"

@class DBShape;

@interface DBLayer : NSObject <NSCopying, NSCoding> {
	NSString *_name;
	NSMutableArray *_shapes;
	DBShape *_tempShape;
	BOOL	_visible;
	BOOL _editable;
	
//	NSImage *_render;
	CGLayerRef _renderLayer;
//	NSSize _layerSize;
	
	DBLayerController	*_layerController;
	
	CGBlendMode _blendMode;
	float _alpha;
	
	NSImage *_backgroundImage;
	NSPoint _bckgrdImagePos;
}
+ (NSArray *)layersWithShapes:(NSArray *)shapes;
- (id)initWithName:(NSString *)name;
     
- (NSString *)name;
- (void)setName:(NSString *)aValue;

- (void)addShape:(DBShape *)aShape;
- (void)addShapes:(NSArray *)someShapes;
- (void)insertShape:(DBShape *)aShape atIndex:(unsigned int)i;
- (DBShape *)shapeAtIndex:(unsigned int)i;
- (unsigned int)indexOfShape:(DBShape *)aShape;
- (void)removeShape:(DBShape *)aShape;
- (void)removeShapeAtIndex:(unsigned int)i;
- (NSArray *)shapes;
- (void)setShapes:(NSArray *)newShapes;
- (void)replaceShape:(DBShape *)shape byShape:(DBShape *)newShape;

- (void)addImage:(NSImage *)image;

- (DBLayerController *)layerController;
- (void)setLayerController:(DBLayerController *)aValue;

- (DBShape *)tempShape;
- (void)setTempShape:(DBShape *)aShape;

- (BOOL)visible;
- (void)setVisible:(BOOL)newVisible;
- (BOOL)editable;
- (void)setEditable:(BOOL)newEditable;


- (void)displayRenderInRect:(NSRect)rect;
- (void)updateRenderInView:(NSView *)view;
- (NSImage *)render;
- (CGLayerRef)renderLayer;
- (void)drawInView:(NSView *)view rect:(NSRect)rect;
- (DBShape *)hitTest:(NSPoint)point;

- (void)updateLayerShapes;
- (void)updateLayerShapesBounds;

- (int)blendMode;
- (void)setBlendMode:(int)newBlendMode;
- (float)alpha;
- (void)setAlpha:(float)newAlpha;
- (float)opacity;
- (void)setOpacity:(float)newOpacity;

- (NSImage *)backgroundImage;
- (void)setBackgroundImage:(NSImage *)aValue;
- (NSPoint)bckgrdImagePos;
- (void)setBckgrdImagePos:(NSPoint)newBckgrdImagePos;

                                     
- (BOOL)lowerShapes:(NSArray *)shapes;
- (BOOL)raiseShapes:(NSArray *)shapes;
@end
