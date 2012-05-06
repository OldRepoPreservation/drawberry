//
//  DBDrawingView+ShapeManagement.m
//  DrawBerry
//
//  Created by Raphael Bost on 02/06/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBDrawingView+ShapeManagement.h"

#import "DBContextualDataSourceController.h"

#import "DBDocument.h"
#import "DBGroupController.h"

#import "DBLayer.h"
#import "DBShape.h"
#import "DBRectangle.h"
#import "DBOval.h"
#import "DBPolyline.h"

#import "EMErrorManager.h"

NSString *DBShapePboardType = @"ShapePboardType";

@class DBRectangle, DBOval;

@implementation DBDrawingView (ShapeManagement)

- (IBAction)delete:(id)sender
{
    [self deleteSelectedShapes];
}
- (void)deleteSelectedShapes
{
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	NSArray *shapeLayers;
	DBShape * shape;
	BOOL showError = NO;
    
	shapeLayers = [self selectedShapesLayers];
	
	while((shape = [e nextObject])){
		if([[shape layer] editable]){
			[[shape layer] removeShape:shape];
		}else{
			showError = YES;
		}
	}
	
	[self deselectAllShapes];
	[shapeLayers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:self];
	[self setNeedsDisplay:YES];
	
	[_dataSourceController updateSelection];
	
	if(showError){
		[_eManager postErrorName:@"Cannot remove all shapes" description:@"You cannot edit a locked layer"];
	}
}

- (IBAction)duplicate:(id)sender
{
    [self duplicateSelectedShapes];
}

- (void)duplicateSelectedShapes
{
	NSData *data;
	NSArray *duplicatedShapes;                                                       
	DBLayer *layer;
    
	data = [NSKeyedArchiver archivedDataWithRootObject:_selectedShapes];
	
	duplicatedShapes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	[duplicatedShapes makeObjectsPerformSelector:@selector(setLayer:) withObject:nil];
	
	NSEnumerator *e = [duplicatedShapes objectEnumerator];
	DBShape * shape;
    
	while((shape = [e nextObject])){
		[shape moveByX:10.0 byY:10.0];
	}
	
	layer = [[self layerController] selectedLayer];
	[layer addShapes:duplicatedShapes];
	[layer updateRenderInView:self];
	[self setNeedsDisplay:YES];	
	
}


- (void)writeShapes:(NSArray *)shapes toPasteboard:(NSPasteboard *)pb
{
	[pb declareTypes:[NSArray arrayWithObject:DBShapePboardType] owner:self];
		
	NSData *shapesData;
	shapesData = [NSKeyedArchiver archivedDataWithRootObject:shapes];
	
	[pb setData:shapesData forType:DBShapePboardType];
}

- (NSArray *)shapesFromPasteboard:(NSPasteboard *)pb
{
	NSData *pbData;
	NSString *type;
	id unarchivedData;
	
	type = [pb availableTypeFromArray:[NSArray arrayWithObject:DBShapePboardType]];
	
	if(type){
		pbData = [pb dataForType:DBShapePboardType];
	   	unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithData:pbData];
				
		return unarchivedData;
	}
	                          
	return nil;
}

- (IBAction)convertRectInPath:(id)sender
{
	[self convertSelectedShapesToBezier];
}                                

- (void)convertSelectedShapesToBezier
{
	NSMutableArray *shapesToConvert = [[NSMutableArray alloc] init];
	NSMutableArray *convertedShapes = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		if([shape isKindOfClass:[DBRectangle class]] || [shape isKindOfClass:[DBOval class]]){
			[shapesToConvert addObject:shape];
			[convertedShapes addObject:[[(DBRectangle *)shape convertToBezierCurve] autorelease]];
		}
	}
	
	[self replaceShapes:shapesToConvert byShapes:convertedShapes actionName:@"Convert"];
		
	// add undo
	
	[self deselectAllShapes];
	[shapesToConvert release];
	[convertedShapes release];
	
	[_dataSourceController updateSelection];
}

- (IBAction)convertToCurve:(id)sender
{
	[self convertSelectedShapesToCurve];
}                                

- (void)convertSelectedShapesToCurve
{
	NSMutableArray *shapesToConvert = [[NSMutableArray alloc] init];
	NSMutableArray *convertedShapes = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	while((shape = [e nextObject])){
		if([shape isKindOfClass:[DBPolyline class]]){
			[shapesToConvert addObject:shape];
			[convertedShapes addObject:[(DBPolyline *)shape convertToCurve]];
		}
	}
	
	[self replaceShapes:shapesToConvert byShapes:convertedShapes actionName:@"Convert"];
	
	// add undo
	
	[self deselectAllShapes];
	[shapesToConvert release];
	[convertedShapes release];
	
	[_dataSourceController updateSelection];
}

- (void)replaceShapes:(NSArray *)shapes byShapes:(NSArray *)newShapes actionName:(NSString *)actionName
{
   	int i;
	DBShape *shape, *newShape;
                       
   	for( i = 0; i < [shapes count]; i++ )
   	{                                 
		shape = [shapes objectAtIndex:i];
		newShape = [newShapes objectAtIndex:i];
		
		[newShape setStroke:[shape stroke]];
		[newShape setFills:[shape fills]];
		
		[[shape layer] replaceShape:shape byShape:newShape];		
   	}

	[self setNeedsDisplay:YES]; 
	
//	[newShapes release];

	[[[(DBDocument *)_document specialUndoManager] prepareWithInvocationTarget:self] replaceShapes:newShapes byShapes:[shapes retain] actionName:actionName]; 
	[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(actionName, nil)];
}

- (void)replaceShapes:(NSArray *)shapes byShape:(DBShape *)newShape actionName:(NSString *)actionName
{
//	NSLog(@"shapes to replace : %@ by shape %@", shapes,newShape);
	
	int index;                       
	DBShape *shape;
	             
	shape = [shapes objectAtIndex:0];
	index = [[shape layer] indexOfShape:shape];
	                        
	[[shape layer] insertShape:newShape atIndex:index]; 
	
	NSEnumerator *e = [shapes objectEnumerator];

//	[shapes nextObject];
  
  	while((shape = [e nextObject])){
		[[shape layer] removeShapeAtIndex:[[shape layer] indexOfShape:shape]];
	}                                     
	
	[[newShape layer] updateLayerShapes];
	[[newShape layer] updateLayerShapesBounds];
	[[newShape layer] updateRenderInView:nil];
	 
	[self setNeedsDisplay:YES]; 

	[[[(DBDocument *)_document specialUndoManager] prepareWithInvocationTarget:self] replaceShape:newShape byShapes:[shapes retain] actionName:actionName]; 
	[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(actionName, nil)];
	
}

- (void)replaceShape:(DBShape *)oldShape byShapes:(NSArray *)newShapes actionName:(NSString *)actionName
{
	int index;
	DBLayer *layer;          
	
	layer = [oldShape layer];
	index = [layer indexOfShape:oldShape];
	
	[layer removeShape:oldShape];
	
	NSEnumerator *e = [newShapes reverseObjectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		[layer insertShape:shape atIndex:index];
	}
	
	[self setNeedsDisplay:YES]; 
	
	[[[(DBDocument *)_document specialUndoManager] prepareWithInvocationTarget:self] replaceShapes:newShapes byShape:[oldShape retain] actionName:actionName]; 
	[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(actionName, nil)];
	
}

- (void)raiseSelectedShapes:(id)sender
{
	[self raiseShapesInArray:_selectedShapes];
}   

- (void)raiseShapesInArray:(NSArray *)shapes
{
	if(!shapes || [shapes count] == 0){
		return;
	}   
	
	NSMutableArray *raisedShapes;	
	raisedShapes = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [[self selectedShapesLayers] objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject])){
		[raisedShapes addObjectsFromArray:[layer raiseShapes:shapes]];
	}

	if([raisedShapes count] > 0){
		[[[(DBDocument *)_document specialUndoManager] prepareWithInvocationTarget:self] lowerShapesInArray:raisedShapes];
		
		if(![[(DBDocument *)_document specialUndoManager] isUndoing]){
			[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(@"Raise Shapes", nil)];
		}else {
			[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(@"Lower Shapes", nil)];	
		}

	}
	
	[raisedShapes release];
}

- (void)lowerSelectedShapes:(id)sender
{
	[self lowerShapesInArray:_selectedShapes];
}   

- (void)lowerShapesInArray:(NSArray *)shapes
{
	if(!shapes || [shapes count] == 0){
		return;
	}
	BOOL didChange;
	didChange = NO;
	
	NSMutableArray *loweredShapes;	
	loweredShapes = [[NSMutableArray alloc] init];

	NSEnumerator *e = [[self selectedShapesLayers] objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject])){
		[loweredShapes addObjectsFromArray:[layer lowerShapes:shapes]];
	}
	
	if([loweredShapes count] > 0){
		[[[(DBDocument *)_document specialUndoManager] prepareWithInvocationTarget:self] raiseShapesInArray:loweredShapes]; 

		if(![[(DBDocument *)_document specialUndoManager] isUndoing]){
			[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(@"Lower Shapes", nil)];	
		}else{
			[[(DBDocument *)_document specialUndoManager] setActionName:NSLocalizedString(@"Raise Shapes", nil)];
		}
	}
	
	[loweredShapes release];
}

- (void)alignLeft:(id)sender
{
	NSPoint corner;
	
	corner = [[_selectedShapes objectAtIndex:0] bounds].origin;
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	[e nextObject];
	
	while((shape = [e nextObject])){
		corner.y = [shape bounds].origin.y;
		[shape moveCorner:0 toPoint:corner];
	}
}

- (void)alignCenter:(id)sender
{
	NSPoint corner,center;
	NSSize size;
	
	corner = [[_selectedShapes objectAtIndex:0] bounds].origin;
	size = [[_selectedShapes objectAtIndex:0] bounds].size;
	
	center = corner;
	center.x += size.width/2;
	center.y += size.height/2;
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	[e nextObject];
	
	while((shape = [e nextObject])){
		size = [shape bounds].size;

		corner = center;
		corner.x -= size.width/2;
		corner.y = [shape bounds].origin.y;
		
		[shape moveCorner:0 toPoint:corner];
	}	
}

- (void)alignRight:(id)sender
{
	NSPoint corner;
	
	corner = [[_selectedShapes objectAtIndex:0] bounds].origin;
	corner.x += [[_selectedShapes objectAtIndex:0] bounds].size.width;
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	[e nextObject];
	
	while((shape = [e nextObject])){
		corner.y = [shape bounds].origin.y;
		[shape moveCorner:3 toPoint:corner];
	}	
}

- (void)alignTop:(id)sender
{
	NSPoint corner;
	
	corner = [[_selectedShapes objectAtIndex:0] bounds].origin;
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	[e nextObject];
	
	while((shape = [e nextObject])){
		corner.x = [shape bounds].origin.x;
		[shape moveCorner:0 toPoint:corner];
	}	
}

- (void)alignMiddle:(id)sender
{
	NSPoint corner,center;
	NSSize size;
	
	corner = [[_selectedShapes objectAtIndex:0] bounds].origin;
	size = [[_selectedShapes objectAtIndex:0] bounds].size;
	
	center = corner;
	center.x += size.width/2;
	center.y += size.height/2;
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	[e nextObject];
	
	while((shape = [e nextObject])){
		size = [shape bounds].size;

		corner = center;
		corner.x = [shape bounds].origin.x;
		corner.y -= size.height/2;
		
		[shape moveCorner:0 toPoint:corner];
	}		
}

- (void)alignBottom:(id)sender
{
	NSPoint corner;
	
	corner = [[_selectedShapes objectAtIndex:0] bounds].origin;
	corner.y += [[_selectedShapes objectAtIndex:0] bounds].size.height;
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	
	[e nextObject];
	
	while((shape = [e nextObject])){
		corner.x = [shape bounds].origin.x;
		[shape moveCorner:0 toPoint:corner];
	}	
}

#pragma mark Groups

- (NSSet *)selectedShapesGroups
{
    NSMutableSet *groups = [[NSMutableSet alloc] init];

    for (DBShape* shape in _selectedShapes) {
        if ([shape group]) {
            [groups addObject:[shape group]];
        }
    }
    
    return [groups autorelease];
}

- (NSSet *)selectedShapesWithAssociatedShapes
{
    NSMutableSet *shapes = [NSMutableSet set];
    
    [shapes addObjectsFromArray:_selectedShapes];
    
    for (DBShape* shape in _selectedShapes) {
        if ([shape group]) {
            [shapes addObjectsFromArray:[[shape group] shapes]];
        }
    }

    
    return shapes;
}

- (NSArray *)shapesWithoutGroups
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (DBShape *shape in _selectedShapes) {
        if (![shape group]) {
            [array addObject:shape];
        }
}
    
    return array;
}

- (IBAction)groupSelectedShapes:(id)sender
{
    [[_document groupController] addGroupWithShapes:_selectedShapes];
    [self setNeedsDisplay:YES];
}

- (IBAction)ungroupSelection:(id)sender
{
    [[_document groupController] ungroup:[[self selectedShapesGroups] allObjects]];
}
@end
 