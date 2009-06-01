//
//  DBLayerController.m
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBLayerController.h"
#import "DBLayer.h"
#import "DBCILayer.h"
#import "DBShape.h"

#import "DBFilterStack.h"

#import "DBDocument.h"
#import "DBDrawingView.h"


@implementation DBLayerController 
+ (void)initialize
{
	[self exposeBinding:@"selectionIndex"];
	[self exposeBinding:@"reverseSelectionIndex"];
	[self exposeBinding:@"reverseSelectionIndexes"];
	[self setKeys:[NSArray arrayWithObject:@"selectionIndex"] triggerChangeNotificationsForDependentKey:@"reverseSelectionIndex"];
	[self setKeys:[NSArray arrayWithObject:@"selectionIndex"] triggerChangeNotificationsForDependentKey:@"reverseSelectionIndexes"];
}

- (id)init
{
	self = [super init];
	
	_layers = [[NSMutableArray alloc] init];
		
	return self;
}

- (void)awakeFromNib
{
	if([_layers count] == 0)
	{              
		DBLayer *layer = [[DBLayer alloc] initWithName:NSLocalizedString(@"Background",nil)]; 
	   	[self addLayer:layer];
		[layer release];
	} 
	
/*	[[_document drawingView] addObserver:self 
							  forKeyPath:@"zoom" 
							     options:NSKeyValueObservingOptionNew 
							     context:nil];
*/	
}   

- (void)dealloc
{
	[_layers release];
	
	[super dealloc];
}

#pragma mark Accessors
- (void)addLayer:(DBLayer *)aLayer
{
//	NSLog(@"add layer %@",aLayer);
	[_layers addObject:aLayer];
	[aLayer setLayerController:self];
}

- (void)insertLayer:(DBLayer *)aLayer atIndex:(unsigned int)i 
{
//	NSLog(@"insert layer : %@ index : %d", aLayer,i);
	[_layers insertObject:aLayer atIndex:i];
	[aLayer setLayerController:self];
}

- (DBLayer *)layerAtIndex:(unsigned int)i
{
	return [_layers objectAtIndex:i];
}

- (unsigned int)indexOfLayer:(DBLayer *)aLayer
{
	return [_layers indexOfObject:aLayer];
}

- (void)removeLayerAtIndex:(unsigned int)i
{
	[_layers removeObjectAtIndex:i];
}

- (void)removeLayer:(DBLayer *)aLayer
{
	[_layers removeObject:aLayer];
}

- (unsigned int)countOfLayers
{
	return [_layers count];
}

- (NSArray *)layers
{
	return _layers;
}

- (void)setLayers:(NSArray *)newLayers
{
	if([self reverseSelectionIndex] == 0 && [newLayers count] < [_layers count]){
		[self setSelectionIndex:[self selectionIndex] - 1];
	}
	
	[_layers setArray:newLayers];
	[_layers makeObjectsPerformSelector:@selector(setLayerController:) withObject:self];
	[self updateLayersAndShapes];
	[self updateShapesBounds];
	[self updateLayersRender];
}

- (DBLayer *)previousLayer:(DBLayer *)layer
{
	int index = [self indexOfLayer:layer];
	
	if(index <= 0){
		return nil;
	}else{
		return [self layerAtIndex:index-1];
	}
}   

- (int)selectionIndex
{
	return _selectionIndex;
}

- (void)setSelectionIndex:(int)newSelectionIndex
{
	if(newSelectionIndex != _selectionIndex){
		if([[self selectedLayer] isKindOfClass:[DBCILayer class]]){
			[[self drawingView] setNeedsDisplay:YES];
		}
		
		_selectionIndex = newSelectionIndex;
		     
		if([[self selectedLayer] isKindOfClass:[DBCILayer class]]){
			[[self drawingView] setNeedsDisplay:YES];
		}
	}
}

- (int)reverseSelectionIndex
{
	return ([_layers count] -1 - _selectionIndex);
}

- (void)setReverseSelectionIndex:(int)newReverseSelectionIndex
{
	if(newReverseSelectionIndex >= 0 && newReverseSelectionIndex < [_layers count])
	{
  		[self setSelectionIndex:([_layers count] - 1 - newReverseSelectionIndex)];
	}
}

- (NSIndexSet *)reverseSelectionIndexes
{
	return [NSIndexSet indexSetWithIndex:[self reverseSelectionIndex]];
}

- (void)setReverseSelectionIndexes:(NSIndexSet *)newReverseSelectionIndexes
{
	[self setReverseSelectionIndex:[newReverseSelectionIndexes firstIndex]];
}

- (DBLayer *)selectedLayer
{
	return [self layerAtIndex:[self selectionIndex]];
}

- (void)selectLayer:(DBLayer *)layer
{
	if(layer && /* ![layer isEqualTo:[self selectedLayer]] && */ [_layers containsObject:layer])
	{   
		[self setSelectionIndex:[_layers indexOfObject:layer]];
	}
}

- (DBDrawingView *)drawingView
{
	if ([_document isKindOfClass:[DBDocument class]]) {
		return [_document drawingView];
	}
	return nil;
}

- (DBUndoManager *)documentUndoManager
{
	return [_document specialUndoManager];
}
#pragma mark Layer reordering

- (void)raiseLayerAtIndex:(unsigned int)index reversed:(BOOL)flag
{
	if(flag)
	{                         
		index =  ([_layers count] -1 - index);
	}
	
	if(index < ([_layers count] )){
		NSArray *oldDependentLayers = nil;
		DBLayer *layer = [self layerAtIndex:(index)];
		
		if(index+1 < [self countOfLayers]){
			oldDependentLayers = [NSArray arrayWithObject:[self layerAtIndex:index+1]];
		}
		
		[self willChangeValueForKey:@"layers"];
		[_layers exchangeObjectAtIndex:index withObjectAtIndex:(index+1)];
		[self didChangeValueForKey:@"layers"];	
		
		[[self layerAtIndex:index] updateRenderInView:[self drawingView]]; 
		[[self layerAtIndex:index+1] updateRenderInView:[self drawingView]];
		 
		[oldDependentLayers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:[self drawingView]];	
		[self updateDependentLayers:layer];
		
		[[self drawingView] setNeedsDisplay:YES];   
	}
}

- (void)lowerLayerAtIndex:(unsigned int)index reversed:(BOOL)flag
{
	if(flag)
	{   
		index =  ([_layers count] -1 - index);
    }
 	
	
	if(index > 0){
		NSArray *oldDependentLayers = nil;
		DBLayer *layer = [self layerAtIndex:(index)];
		
		if(index+1 < [self countOfLayers]){
			oldDependentLayers = [NSArray arrayWithObject:[self layerAtIndex:index+1]];
		}

 		[self willChangeValueForKey:@"layers"];
   		[_layers exchangeObjectAtIndex:(index-1) withObjectAtIndex:(index)];
		[self didChangeValueForKey:@"layers"];	
		
		[[self layerAtIndex:index] updateRenderInView:[self drawingView]]; 
		[[self layerAtIndex:index-1] updateRenderInView:[self drawingView]];
		 
		[oldDependentLayers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:[self drawingView]];	
		[self updateDependentLayers:layer];
		
		[[self drawingView] setNeedsDisplay:YES];   
 	}
}  

- (void)raiseAtTopLayerAtIndex:(unsigned int)index reversed:(BOOL)flag
{
	if(flag)
	{
		index =  ([_layers count] -1 - index);
	}
	
	if(index < ([_layers count] )){
		NSArray *oldDependentLayers = nil;
		DBLayer *layer = [self layerAtIndex:(index)];
		
		if(index+1 < [self countOfLayers]){
			oldDependentLayers = [NSArray arrayWithObject:[self layerAtIndex:index+1]];
		}
		
		
 		[self willChangeValueForKey:@"layers"];
//		id layer = [self layerAtIndex:index];
		[layer retain];
		[self removeLayer:layer];
		[self insertLayer:layer atIndex:[_layers count]];	
		[self didChangeValueForKey:@"layers"];	
		
		[layer updateRenderInView:[self drawingView]]; 
		 
		[oldDependentLayers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:[self drawingView]];	
		[self updateDependentLayers:layer];
		
		[[self drawingView] setNeedsDisplay:YES];
	}
} 

- (void)lowerAtBottomLayerAtIndex:(unsigned int)index reversed:(BOOL)flag
{
	if(flag)
	{                         
		index =  ([_layers count] -1 - index);
	} 
	if(index > 0){
 		NSArray *oldDependentLayers = nil;
		DBLayer *layer = [self layerAtIndex:(index)];
		
		if(index+1 < [self countOfLayers]){
			oldDependentLayers = [NSArray arrayWithObject:[self layerAtIndex:index+1]];
		}
		
		[self willChangeValueForKey:@"layers"];
//		id layer = [self layerAtIndex:index];
		[layer retain];
		[self removeLayer:layer];
		[self insertLayer:layer atIndex:0];
		[self didChangeValueForKey:@"layers"];
		
		[layer updateRenderInView:[self drawingView]]; 
		 
		[oldDependentLayers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:[self drawingView]];	
		[self updateDependentLayers:layer];
		
		[[self drawingView] setNeedsDisplay:YES];   
	 }
}

- (NSIndexSet *)reverseIndexSet:(NSIndexSet *)indexes
{
	NSMutableIndexSet *reversedInd = [[NSMutableIndexSet alloc] init];
	unsigned int *indexBuffer;
	int i;
	int layerCount = [_layers count];
	
	indexBuffer = malloc([indexes count]*sizeof(unsigned int));
	
	[indexes getIndexes:indexBuffer maxCount:[indexes count] inIndexRange:nil];
	

	for( i = 0; i < [indexes count]; i++ )
	{
		[reversedInd addIndex:(layerCount - 1 - indexBuffer[i])];
	}
	
	free(indexes);
	
	return [indexes autorelease];
}   

- (void)moveRowsAtIndex:(int)oldIndex toIndex:(int)newIndex reversed:(BOOL)flag
{

	if(flag){
		oldIndex =  ([_layers count] -1 - oldIndex);
		newIndex =  ([_layers count] -1 - newIndex);
	}   
	
	if(newIndex > oldIndex){
		newIndex -= 1;
	}
	
	DBLayer *movedLayer = [[self layerAtIndex:oldIndex] retain];
	NSArray *oldDependentLayers = nil;
	if(oldIndex+1 < [self countOfLayers]){
		oldDependentLayers = [NSArray arrayWithObject:[self layerAtIndex:oldIndex+1]];
	}

	[self willChangeValueForKey:@"layers"];
	[_layers removeObject:movedLayer];
	[_layers insertObject:movedLayer atIndex:newIndex];                                           
	[self didChangeValueForKey:@"layers"];
    
	[movedLayer updateRenderInView:[self drawingView]]; 
	 
	[oldDependentLayers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:[self drawingView]];	
	[self updateDependentLayers:movedLayer];

	[[self drawingView] setNeedsDisplay:YES];   
}                                                                                        

#pragma mark Drawing and Updating Layers

- (void)drawLayersInRect:(NSRect)rect
{
//	NSLog(@"display all layers; selected layers : %@", [self selectedLayer]);
	NSMutableArray *layersToDraw;
 	DBLayer *layer, *editingLayer;
	NSArray *selectedLayers;
	BOOL _toScreen;
	
	_toScreen = [NSGraphicsContext currentContextDrawingToScreen];
	
	layersToDraw = [NSMutableArray arrayWithArray:_layers];
    NSEnumerator *e = [_layers objectEnumerator];
    
   	while((layer = [e nextObject])){
    	if([layer isKindOfClass:[DBCILayer class]] && [layer visible]){
			if(![(DBCILayer *)layer drawUnderneathLayers])
				[layersToDraw removeObjectsInArray:[(DBCILayer *)layer underneathLayers]];
		}
	}
	
	e = [layersToDraw objectEnumerator];
	
     
	selectedLayers = [[_document drawingView] selectedShapesLayers];
	editingLayer =  [[[_document drawingView] editingShape] layer];
	
   	while((layer = [e nextObject])){
		if([layer visible]){
			if([selectedLayers containsObject:layer] || layer == editingLayer || !_toScreen)
			{
			 	[layer drawInView:[self drawingView] rect:rect];
			}else{
//				[layer displayRenderInRect:rect];
				[layer drawInView:[self drawingView] rect:rect];
			}
		}
	}
}

- (void)drawDirectlyLayersInRect:(NSRect)rect
{
		NSMutableArray *layersToDraw;
	 	DBLayer *layer;
		BOOL _toScreen;

		_toScreen = [NSGraphicsContext currentContextDrawingToScreen];

		layersToDraw = [NSMutableArray arrayWithArray:_layers];
	    NSEnumerator *e = [_layers objectEnumerator];

	   	while((layer = [e nextObject])){
	    	if([layer isKindOfClass:[DBCILayer class]] && [layer visible]){
				if(![(DBCILayer *)layer drawUnderneathLayers])
					[layersToDraw removeObjectsInArray:[(DBCILayer *)layer underneathLayers]];
			}
		}

		e = [layersToDraw objectEnumerator];

	   	while((layer = [e nextObject])){
			if([layer visible]){
		  		[layer drawInView:[self drawingView] rect:rect];
			}
		}	
}

- (void)updateDependentLayers:(DBLayer *)layer
{
	int index;
	index = [self indexOfLayer:layer];
	
		if(index+1 < [self countOfLayers]){
			[[self layerAtIndex:index+1] updateRenderInView:[self drawingView]];
		}
}   

- (void)updateLayersRender
{
	NSAutoreleasePool *pool;
		
	[_layers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:[self drawingView]];
	
	NSEnumerator *e = [_layers objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject])){ 
		pool = [[NSAutoreleasePool alloc] init];
		[layer updateRenderInView:[self drawingView]];
		[pool release];
	}
} 

- (void)needsDisplay
{
	[[_document drawingView] setNeedsDisplay:YES];
}

- (DBShape *)hitTest:(NSPoint)point
{
	if( abs(point.x) <= 1e-5){
		point.x = 0;
	}
	if( abs(point.y) <= 1e-5){
		point.y = 0;
	}
	NSEnumerator *e = [_layers reverseObjectEnumerator];
	DBLayer  *layer;
	DBShape *shape = nil;

	while((layer = [e nextObject]) && (shape == nil)){
		shape = [layer hitTest:point];
	}
	return shape;
}

- (void)updateLayersAndShapes
{
	[_layers makeObjectsPerformSelector:@selector(updateLayerShapes)];
} 

- (void)updateShapesBounds
{
	[_layers makeObjectsPerformSelector:@selector(updateLayerShapesBounds)];
}

#pragma mark Actions

- (IBAction)addCILayer:(id)sender
{
	DBCILayer *ciLayer;

	ciLayer = [[DBCILayer alloc] initWithName:NSLocalizedString(@"CILayer",nil)];
	[self addLayer:ciLayer];
	[ciLayer release];
	
	[[ciLayer filterStack] addFilter:sender];
	if([[[ciLayer filterStack] effects] layerCount] == 0){
		[self removeLayer:ciLayer];
	}else{                               
  	[self updateLayersAndShapes];
	[[self drawingView] setNeedsDisplay:YES];
	
	[self selectLayer:ciLayer];
	}
}

- (void)addImageToCurrentLayer:(NSImage *)image
{
	[[self selectedLayer] addImage:image];
}
#pragma mark Notifications and Observation 
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[self updateLayersAndShapes];
	[self updateLayersRender];
	
//	[NSThread detachNewThreadSelector:@selector(updateLayersRender) toTarget:self withObject:nil];
}

- (BOOL)isEditing
{
	return _isEditing;
}

- (void)setIsEditing:(BOOL)newIsEditing
{
	_isEditing = newIsEditing;
}

- (void)beginEditing
{
	[self setIsEditing:YES];
}
- (void)endEditing
{     
	[self setIsEditing:NO];
}

- (DBLayer *)editingLayer
{
	if(_isEditing){
		return [self selectedLayer];
	}
	return nil;
}
@end
