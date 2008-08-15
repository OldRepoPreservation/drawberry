//
//  DBDrawingView+ShapeManagement.m
//  DrawBerry
//
//  Created by Raphael Bost on 02/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingView+ShapeManagement.h"

#import "DBLayer.h"
#import "DBShape.h"

#import "EMErrorManager.h"

NSString *DBShapePboardType = @"ShapePboardType";

@class DBRectangle, DBOval;

@implementation DBDrawingView (ShapeManagement)

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
	
	if(showError){
		[_eManager postErrorName:@"Cannot remove all shapes" description:@"You cannot edit a locked layer"];
	}
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
	[self convertSelectedShapes];
}                                

- (void)convertSelectedShapes
{
	NSMutableArray *shapesToConvert = [[NSMutableArray alloc] init];
	NSMutableArray *convertedShapes = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		if([shape isKindOfClass:[DBRectangle class]] || [shape isKindOfClass:[DBOval class]]){
			[shapesToConvert addObject:shape];
			[convertedShapes addObject:[[shape convert] autorelease]];
		}
	}
	
	[self replaceShapes:shapesToConvert byShapes:convertedShapes actionName:@"Convert"];
		
	// add undo
	
	[self deselectAllShapes];
	[shapesToConvert release];
	[convertedShapes release];
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
		[newShape setFill:[shape fill]];
		
		[[shape layer] replaceShape:shape byShape:newShape];		
   	}

	[self setNeedsDisplay:YES]; 
	
//	[newShapes release];

	[[[_document specialUndoManager] prepareWithInvocationTarget:self] replaceShapes:newShapes byShapes:[shapes retain] actionName:actionName]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(actionName, nil)];
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

	[[[_document specialUndoManager] prepareWithInvocationTarget:self] replaceShape:newShape byShapes:[shapes retain] actionName:actionName]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(actionName, nil)];
	
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
	
	[[[_document specialUndoManager] prepareWithInvocationTarget:self] replaceShapes:newShapes byShape:[oldShape retain] actionName:actionName]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(actionName, nil)];
	
}

- (void)raiseSelectedShapes:(id)sender
{
	[self raiseShapes:_selectedShapes];
}   

- (void)raiseShapes:(NSArray *)shapes
{
	if(!shapes || [shapes count] == 0){
		return;
	}   
	
	BOOL didChange;
	didChange = NO;
	
	NSEnumerator *e = [[self selectedShapesLayers] objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject])){
		didChange = ([layer raiseShapes:shapes]) ? YES : didChange;
	}

	if(didChange){
	[[[_document specialUndoManager] prepareWithInvocationTarget:self] raiseShapes:shapes]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(@"Raise", nil)];
	}
}

- (void)lowerSelectedShapes:(id)sender
{
	[self lowerShapes:_selectedShapes];
}   

- (void)lowerShapes:(NSArray *)shapes
{
	if(!shapes || [shapes count] == 0){
		return;
	}
	BOOL didChange;
	didChange = NO;
	
	NSEnumerator *e = [[self selectedShapesLayers] objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject])){
		didChange = ([layer lowerShapes:shapes]) ? YES : didChange;
	}
	
	if(didChange){
		[[[_document specialUndoManager] prepareWithInvocationTarget:self] raiseShapes:shapes]; 
		[[_document specialUndoManager] setActionName:NSLocalizedString(@"Lower", nil)];	
	}
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
@end
 