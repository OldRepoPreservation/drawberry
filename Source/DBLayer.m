//
//  DBLayer.m
//  DrawBerry
//
//  Created by Raphael Bost on 10/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBLayer.h"
#import "DBShape.h"


#import "DBRectangle.h"

#import "DBDrawingView.h"

#import "DBUndoManager.h"


@implementation DBLayer
+ (void)initialize
{
	[self exposeBinding:@"name"];
	
//	[[DBUndoStack class] poseAsClass:[_NSUndoStack class]];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    NSSet *affectingKeys = nil;
    
    if ([key isEqualToString:@"opacity"]){
        affectingKeys = [NSSet setWithObject:@"alpha"];
    }
    
    keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    
    return keyPaths;
}

+ (NSArray *)layersWithShapes:(NSArray *)shapes
{
	NSMutableArray *layers;
	layers = [NSMutableArray array];
	
	NSEnumerator *e = [shapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		if(![layers containsObject:[shape layer]])
			[layers addObject:[shape layer]];
	}
	
	return layers;
}
- (id)init
{
	self = [self initWithName:NSLocalizedString(@"New Layer",nil)];
		
	return self;
}

- (id)initWithName:(NSString *)name
{
	self = [super init];
	
	_shapes = [[NSMutableArray alloc] init];
	_visible = YES;
	_editable = YES;
	_blendMode = kCGBlendModeNormal;
	_alpha = 1.0;
	_bckgrdImagePos = NSZeroPoint;
	
	[self setName:name];
	 
	return self;
}                      

- (id)copyWithZone:(NSZone *)zone
{
	DBLayer *layer;
	NSArray *shapesCopy;
	
	layer = [[DBLayer allocWithZone:zone] initWithName:[self name]];
	
	shapesCopy = [[NSArray alloc] initWithArray:[self shapes] copyItems:YES];
	[layer setShapes:shapesCopy];
	[shapesCopy release];
	[layer setBackgroundImage:[self backgroundImage]];
	[layer setBckgrdImagePos:_bckgrdImagePos];
	
	return layer;
}

- (void)dealloc
{
	[_name release];
	[_shapes release];
	CGLayerRelease(_renderLayer);
	[_backgroundImage release];
	
	[super dealloc];
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self initWithName:[decoder decodeObjectForKey:@"Layer Name"]];
	
	_visible = [decoder decodeBoolForKey:@"Visible"];
	_editable = [decoder decodeBoolForKey:@"Editable"];
	[self setShapes:[decoder decodeObjectForKey:@"Shapes"]]; 
	_blendMode = [decoder decodeIntForKey:@"Blend Mode"];
	_alpha = [decoder decodeFloatForKey:@"Alpha"];
	[self setBackgroundImage:[decoder decodeObjectForKey:@"Background Image"]];
	_bckgrdImagePos = [decoder decodePointForKey:@"Background Image Position"];
		
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_name forKey:@"Layer Name"];
	[encoder encodeBool:_visible forKey:@"Visible"];
	[encoder encodeBool:_editable forKey:@"Editable"];
	[encoder encodeObject:_shapes forKey:@"Shapes"];
	[encoder encodeInt:_blendMode forKey:@"Blend Mode"];
	[encoder encodeFloat:_alpha forKey:@"Alpha"];
	[encoder encodeObject:_backgroundImage forKey:@"Background Image"];
	[encoder encodePoint:_bckgrdImagePos forKey:@"Background Image Position"];
	
}

#pragma mark Accessors
- (NSString *)name
{
	return _name;
}

- (void)setName:(NSString *)oldName
{
	DBUndoManager *undo = [_layerController documentUndoManager];
	[(DBLayer *)[undo prepareWithInvocationTarget:self] setName:[self name]];
	[undo setActionName:NSLocalizedString(@"Change Layer Name", nil)];		

	
	[oldName retain];
	[_name release];
	_name = oldName;
}

- (void)addShape:(DBShape *)aShape
{
	[_shapes addObject:aShape];
	
	if(aShape == _tempShape)
	{   
		[_tempShape release];
		_tempShape = nil;
	}	
	[aShape setLayer:self]; 
	[aShape updateShape];
	[aShape updateBounds];
	
	[self updateRenderInView:nil];
	
	DBUndoManager *undo = [_layerController documentUndoManager];
	[[undo prepareWithInvocationTarget:self] removeShape:aShape];
	
	if(![undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Insert Shape", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Delete Shape", nil)];
	}   
	
	if([undo isUndoing] || [undo isRedoing]){
//	   	[[_layerController drawingView] selectShape:aShape];
	   	[self updateRenderInView:nil];
		[[_layerController drawingView] setNeedsDisplay:YES];
	}
}

- (DBShape *)tempShape
{
	return _tempShape;
}                     

- (void)setTempShape:(DBShape *)aShape
{	
	[aShape retain];	
	
	[_tempShape release];
	_tempShape = aShape;
	
	[_tempShape setLayer:self]; 
	[_tempShape updateShape];
	[_tempShape updateBounds];
}

- (void)addShapes:(NSArray *)someShapes
{
	NSEnumerator *e = [someShapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		[self addShape:shape];
	}
}

- (void)insertShape:(DBShape *)aShape atIndex:(unsigned int)i 
{
	[_shapes insertObject:aShape atIndex:i];
	
	[aShape setLayer:self];
	[aShape updateShape];
	[aShape updateBounds];
	
	[self updateLayerShapes];
	[self updateLayerShapesBounds];
	[self updateRenderInView:nil];
}

- (DBShape *)shapeAtIndex:(unsigned int)i
{
	return [_shapes objectAtIndex:i];
}

- (unsigned int)indexOfShape:(DBShape *)aShape
{
	return [_shapes indexOfObject:aShape];
}

- (void)removeShapeAtIndex:(unsigned int)i
{
	[_shapes removeObjectAtIndex:i];
}

- (void)removeShape:(DBShape *)aShape
{
	DBUndoManager *undo = [_layerController documentUndoManager];
	[[undo prepareWithInvocationTarget:self] addShape:aShape];
	
	if(![undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Delete Shape", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Insert Shape", nil)];	
	}

	[_shapes removeObject:aShape];
	
	if([undo isUndoing] || [undo isRedoing]){
		[[_layerController drawingView] deselectAllShapes];
		[self updateRenderInView:nil];
		[[_layerController drawingView] setNeedsDisplay:YES];
	}
}

- (unsigned int)countOfShapes
{
	return [_shapes count];
}

- (NSArray *)shapes
{
	return _shapes;
}

- (void)setShapes:(NSArray *)newShapes
{
	[_shapes makeObjectsPerformSelector:@selector(setLayer:) withObject:nil	];
	[_shapes setArray:[NSMutableArray arrayWithArray:newShapes]];
	[_shapes makeObjectsPerformSelector:@selector(setLayer:) withObject:self];
}

- (void)replaceShape:(DBShape *)shape byShape:(DBShape *)newShape
{
	int index;
	index = [_shapes indexOfObject:shape];
	
	[newShape updateShape];
	[newShape updateBounds];
	
	[_shapes replaceObjectAtIndex:index withObject:newShape];                         
	
	[newShape setLayer:self];
	[self updateLayerShapes];
	[self updateLayerShapesBounds];
	[self updateRenderInView:nil];
}

- (void)addImage:(NSImage *)image
{
	DBRectangle *rectShape;
	NSRect rect;
	NSSize canevasSize,imageSize;
	float imageSizeScale;                                                  
	
	canevasSize = [[_layerController drawingView] canevasSize];
	imageSize = [image size];
	rect.origin = NSMakePoint(canevasSize.width/2,canevasSize.height/2);
	
//	canevasSize.width *= 0.8;       // take 80% of the canevas size
//	canevasSize.height *= 0.8;
	
	imageSizeScale = imageSize.height /  imageSize.width;
	
	if(imageSizeScale >= 1){
		if(imageSize.height <= canevasSize.height){
			rect.size = imageSize;
		}else{
			rect.size = NSMakeSize(canevasSize.height/imageSizeScale,canevasSize.height);
		}
	}else{
		if(imageSize.width <= canevasSize.width){
			rect.size = imageSize;
		}else{
			rect.size = NSMakeSize(canevasSize.width,canevasSize.width*imageSizeScale);
		}
	}                         
	
	rect.origin.x -= rect.size.width / 2;
	rect.origin.y -= rect.size.height / 2;
	
//	rectShape = [[DBRectangle alloc] initWithRect:NSMakeRect(50,50,50,50)];
	rectShape = [[DBRectangle alloc] initWithRect:rect];
	
	[self addShape:rectShape];

	[rectShape updatePath];
	[rectShape updateBounds];
	
	DBFill *fill;
	
	fill = [[DBFill alloc] initWithShape:rectShape];
	[rectShape addFill:fill];
	
	[[rectShape fillAtIndex:0] setFillMode:DBImageFillMode];
	[[rectShape fillAtIndex:0] setImageFillMode:DBDrawMode];
	[[rectShape fillAtIndex:0] setFillImage:image];
	[[rectShape stroke] setStrokeMode:DBNoStrokeMode];
	
	[fill release];
	[rectShape release];

	
	[self updateRenderInView:[_layerController drawingView]];
	[[_layerController drawingView] setNeedsDisplay:YES];
}   

- (BOOL)visible
{
	return _visible;
}

- (void)setVisible:(BOOL)newVisible
{
	DBUndoManager *undo = [_layerController documentUndoManager];
	[(DBLayer *)[undo prepareWithInvocationTarget:self] setVisible:[self visible]];
	
	if(newVisible ^ [undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Show Layer", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Hide Layer", nil)];	
	}
	
	if(_visible != newVisible){
		_visible = newVisible;
		[_layerController needsDisplay];
	}
}

- (BOOL)editable
{
 	return _editable;
}

- (void)setEditable:(BOOL)newEditable
{
	DBUndoManager *undo = [_layerController documentUndoManager];
	[(DBLayer *)[undo prepareWithInvocationTarget:self] setEditable:[self editable]];
	
	if(newEditable ^ [undo isUndoing]){
		[undo setActionName:NSLocalizedString(@"Unlock Layer", nil)];
	}else{
		[undo setActionName:NSLocalizedString(@"Lock Layer", nil)];	
	}
	
	
	_editable = newEditable;
}

/*- (NSSize)layerSize
{
	return _layerSize;
}

- (void)setLayerSize:(NSSize)newLayerSize
{
	_layerSize = newLayerSize;
	[self updateRender];
}
*/ 

- (DBLayerController *)layerController
{
	return _layerController;
}

- (void)setLayerController:(DBLayerController *)newLayerController
{
	if(_layerController != newLayerController){
		_layerController = newLayerController;
		
		if(_layerController)	// layer controller is not nil
			[self updateRenderInView:[_layerController drawingView]];     
		
		
	}
}

- (int)blendMode
{
	return _blendMode;
}

- (void)setBlendMode:(int)newBlendMode
{
	DBUndoManager *undo = [_layerController documentUndoManager];
	[(DBLayer *)[undo prepareWithInvocationTarget:self] setBlendMode:[self blendMode]];
	[undo setActionName:NSLocalizedString(@"Change Layer Blend Mode", nil)];
		
	
	_blendMode = newBlendMode;
	[[_layerController drawingView] setNeedsDisplay:YES];
}

- (float)alpha
{
	return _alpha;
}

- (void)setAlpha:(float)newAlpha
{
	if(newAlpha != _alpha){
		_alpha = newAlpha;
		[[_layerController drawingView] setNeedsDisplay:YES];
	}
}

- (float)opacity
{
	return _alpha*100.0;
}

- (void)setOpacity:(float)newOpacity
{
	[self setAlpha:(newOpacity/100.0)];
}

- (NSImage *)backgroundImage
{
	return _backgroundImage;
}

- (void)setBackgroundImage:(NSImage *)newBackgroundImage
{
	[newBackgroundImage retain];
	[_backgroundImage release];
	_backgroundImage = newBackgroundImage;
	
	[self updateRenderInView:[_layerController drawingView]];
}

- (NSPoint)bckgrdImagePos
{
	return _bckgrdImagePos;
}

- (void)setBckgrdImagePos:(NSPoint)newBckgrdImagePos
{
	_bckgrdImagePos = newBckgrdImagePos;
	[self updateRenderInView:[_layerController drawingView]];
}


- (DBUndoManager *)undoManager
{
	return [_layerController documentUndoManager];
}
#pragma mark Shape Hierarchy

- (NSArray *)lowerShapes:(NSArray *)shapes // return the shapes that have really been lowered
{
	if(!_editable){
		return nil;
	}        
	
	NSEnumerator *e = [shapes objectEnumerator];
	DBShape * shape;
	int index;
	NSMutableArray *loweredShapes; // this array will record the shape that will really be moved
	
	loweredShapes = [[NSMutableArray alloc] init];
	
	while((shape = [e nextObject])){
		index = [_shapes indexOfObject:shape];
		
		if(index == 0 || index == NSNotFound){
			continue; // cannot lower the lowest shape
		}else{
			[loweredShapes addObject:shape];
			[_shapes exchangeObjectAtIndex:index withObjectAtIndex:index-1];
		}
	}
	
	[self updateRenderInView:[[self layerController] drawingView]];
	[[[self layerController] drawingView] setNeedsDisplay:YES];	

//	if (didChange) {
//		DBUndoManager *undo = [_layerController documentUndoManager];
//		[(DBLayer *)[undo prepareWithInvocationTarget:self] raiseShapes:loweredShapes];
//		[undo setActionName:NSLocalizedString(@"Lower Shapes", nil)];		
//	}
	
	return [loweredShapes autorelease];
}

- (NSArray *)raiseShapes:(NSArray *)shapes // return the shapes that have really been raised
{
	if(!_editable){
		return nil;
	}
	
	NSEnumerator *e = [shapes objectEnumerator];
	DBShape * shape;
	int index;
	NSMutableArray *raisedShapes; // this array will record the shape that will really be moved

	raisedShapes = [[NSMutableArray alloc] init];
	while((shape = [e nextObject])){
		index = [_shapes indexOfObject:shape];
		
		if(index == [self countOfShapes]-1 || index == NSNotFound){
			continue; // cannot raise the higher shape
		}else{
			[raisedShapes addObject:shape];
			[_shapes exchangeObjectAtIndex:index withObjectAtIndex:index+1];
		}
	}
	
	[self updateRenderInView:[[self layerController] drawingView]];
	[[[self layerController] drawingView] setNeedsDisplay:YES];	
	
//	if (didChange) {
//		DBUndoManager *undo = [_layerController documentUndoManager];
//		[(DBLayer *)[undo prepareWithInvocationTarget:self] raiseShapes:raisedShapes];
//		[undo setActionName:NSLocalizedString(@"Lower Shapes", nil)];		
//	}
	
	return [raisedShapes autorelease];
}

#pragma mark Display

- (void)displayRenderInRect:(NSRect)rect
{
/*	[_render compositeToPoint:NSZeroPoint fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[_render drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
*/   
		
	NSGraphicsContext *mainContext = [NSGraphicsContext currentContext] ;
                                                                                
	CGContextSaveGState([mainContext graphicsPort]);
	
	// if([_layerController indexOfLayer:self] == 0){
	// 	CGContextSetBlendMode([mainContext graphicsPort], kCGBlendModeNormal);
	// }else{
		CGContextSetBlendMode([mainContext graphicsPort], _blendMode);
		CGContextSetAlpha([mainContext graphicsPort], _alpha);
	// }
	
  	CGContextDrawLayerAtPoint ([mainContext graphicsPort], CGPointMake(0,0), _renderLayer);

	CGContextRestoreGState([mainContext graphicsPort]);
}

- (void)updateRenderInView:(NSView *)view
{
	[self willChangeValueForKey:@"render"];
    
	if(view == nil)
		view = [_layerController drawingView];
	
	if(_layerController == nil){
		//there is a problem
		CGLayerRelease(_renderLayer);
		_renderLayer = NULL;
		return;
	}

//	[_render release];
/*    if(!_render){
		_render = [[NSImage alloc] initWithSize:[[_layerController drawingView] zoomedCanevasSize]];
		[_render setScalesWhenResized:NO];
    }else
		[_render setSize: [[_layerController drawingView] zoomedCanevasSize]];
	// draw the layer into the image
	
	[_render lockFocus];
	[self drawInView:[_layerController drawingView] rect:NSZeroRect];
	[_render unlockFocus];
    */       
	

	NSSize size = [(DBDrawingView *)view canevasSize];
    
	NSGraphicsContext *mainContext = [NSGraphicsContext currentContext] ;
	[mainContext retain];
	
	CGLayerRelease(_renderLayer);
	_renderLayer = CGLayerCreateWithContext((CGContextRef)[mainContext graphicsPort], (CGSizeMake(size.width, size.height)), NULL);
//	_renderLayer = [[mainContext CIContext] createCGLayerWithSize:CGSizeMake(size.width, size.height) info:NULL];
	
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:CGLayerGetContext(_renderLayer) flipped:YES]];
    
	[NSGraphicsContext saveGraphicsState] ;
	                                             
	NSAffineTransform * af = [NSAffineTransform transform];
	[af scaleBy:[(DBDrawingView *)view zoom]];
	NSPoint point =  [(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_bckgrdImagePos];
	point.x /=  [(DBDrawingView *)view zoom];
	point.y /=  [(DBDrawingView *)view zoom];
	
	[af concat];

//	[_backgroundImage compositeToPoint:[(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_bckgrdImagePos] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:_alpha];
	[_backgroundImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];		
	
	[NSGraphicsContext restoreGraphicsState];
	
	NSEnumerator *e = [_shapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		[shape drawInView:view rect:NSZeroRect];
	}
	
	if(_tempShape){
		[_tempShape drawInView:view rect:NSZeroRect];
	}
//	NSLog(@"layer %@ updated : %d",[self name], _renderLayer);
	[NSGraphicsContext setCurrentContext:mainContext];
	
	                                    
	[mainContext release];
	[self didChangeValueForKey:@"render"];
}   

- (NSImage *)render
{
//	return _render;
	return nil;
}                  

- (CGLayerRef)renderLayer
{
	return _renderLayer;
}

- (void)drawInView:(NSView *)view rect:(NSRect)rect
{
   //NSLog(@"draw layer : %@", self);

	NSGraphicsContext *mainContext = [NSGraphicsContext currentContext] ;

//	[_backgroundImage compositeToPoint:[(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_bckgrdImagePos] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:_alpha];
	
	
//	[_backgroundImage drawAtPoint:[(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_bckgrdImagePos] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];		

	[NSGraphicsContext saveGraphicsState] ;
	NSAffineTransform * af = [NSAffineTransform transform];
	[af scaleBy:[(DBDrawingView *)view zoom]];
	NSPoint point =  [(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_bckgrdImagePos];
	point.x /=  [(DBDrawingView *)view zoom];
	point.y /=  [(DBDrawingView *)view zoom];

	[af concat];

//	[_backgroundImage compositeToPoint:[(DBDrawingView *)view viewCoordinatesFromCanevasCoordinates:_bckgrdImagePos] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:_alpha];
	[_backgroundImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];		

	[NSGraphicsContext restoreGraphicsState];


	CGContextSaveGState([mainContext graphicsPort]);
	
//	if([_layerController indexOfLayer:self] == 0){
//		CGContextSetBlendMode([mainContext graphicsPort], kCGBlendModeNormal);
//	}else{
		CGContextSetBlendMode([mainContext graphicsPort], _blendMode);
		CGContextSetAlpha([mainContext graphicsPort], _alpha);
//	}
	
	
	NSEnumerator *e = [_shapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		[shape drawInView:view rect:rect];
	}
    
	if(_tempShape){
		[_tempShape drawInView:view rect:rect];
	}
    
	CGContextRestoreGState([mainContext graphicsPort]);

//	[self displayRenderInRect:rect];
}  

- (DBShape *)hitTest:(NSPoint)point
{
	NSEnumerator *e = [_shapes reverseObjectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		if([shape hitTest:point])
		{
			break;
		}
	}
	
	return shape;
}

- (void)updateLayerShapes
{
	[_shapes makeObjectsPerformSelector:@selector(updateShape)];
	[_shapes makeObjectsPerformSelector:@selector(updateFill)];
	[_tempShape updateShape];
	[_tempShape updateFill];
}

- (void)updateLayerShapesBounds
{
	[_shapes makeObjectsPerformSelector:@selector(updateBounds)];
	[_tempShape updateBounds];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ ; name : %@ ; shapes %@",[super description],[self name], _shapes];
}

@end
