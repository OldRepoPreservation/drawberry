//
//  DBShapeLibLayerController.m
//  DrawBerry
//
//  Created by Raphael Bost on 18/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBShapeLibLayerController.h"

#import "DBShapeLibraryController.h"
#import "DBShape.h"
#import "DBLayer.h"

@implementation DBShapeLibLayerController
- (void)drawLayersInRect:(NSRect)rect
{
	[self drawDirectlyLayersInRect:rect];
	
//	[_editedShape drawInView:_shapeEditor rect:[_editedShape bounds]];	
}  

/*- (DBShape *)hitTest:(NSPoint)point
{
	if([_editedShape hitTest:point]){
		return _editedShape;
	}
	
	return nil;
}*/

- (void)editShape:(DBShape *)shape
{                        
	if(shape == _editedShape){
		return;
	}
	[[self layerAtIndex:0] removeShape:_editedShape];
	
	if(shape){
		[[self layerAtIndex:0] setShapes:[NSArray arrayWithObject:shape]];		
	}
	                            
//	[self upd]
	_editedShape = shape;
//	[self updateLayersRender];
	[_shapeEditor deselectAllShapes];
	[_shapeEditor setNeedsDisplay:YES];
}

- (DBShape *)editedShape
{
	return _editedShape;
}

- (DBDrawingView *)drawingView
{
	return _shapeEditor;
}

- (void)addShape:(DBShape *)shape
{                        
	_editedShape = shape;
	[_shapeEditor setNeedsDisplay:YES];
//   [_libController newShape:_editedShape];
}

- (void)removeEditedShape
{                                              
	[_libController removeEditedShape];
}

- (void)endEditing
{
	[super endEditing];
	
	int count;
	count = [[[self layerAtIndex:0] shapes] count];
	
	if((!_editedShape || count > 1) && count > 0){
		_editedShape = [[self layerAtIndex:0] shapeAtIndex:(count - 1)];
		[_libController newShape:_editedShape];
//		[[self layerAtIndex:0] setShapes:[NSArray arrayWithObject:_editedShape]];
	}
	
	[_libController reload:self];
}
@end
