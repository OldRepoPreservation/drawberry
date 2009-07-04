//
//  DBLayer+BooleanOps.m
//  DrawBerry
//
//  Created by Raphael Bost on 14/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingView.h"
#import "DBDrawingView+BooleanOps.h"
#import "DBDrawingView+ShapeManagement.h"

#import "NSBezierPath+GPC.h"
#import "DBShape.h"
#import "DBBezierCurve.h"


@implementation DBDrawingView (BooleanOps)
///*********************************************************************************************************************
///
/// method:			unionSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	forms the union of the selected objects and replaces the selection with the result
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			result adopts the style of the topmost object contributing.
///
///********************************************************************************************************************

- (IBAction)		unionSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*			sel = [[NSArray alloc] initWithArray:_selectedShapes];
	NSEnumerator*		iter = [sel objectEnumerator];
	DBShape*	obj;
	DBShape*	result;
	NSBezierPath*		rp = nil;
	 
	if([[self selectedShapesLayers] count]>1){
		[_eManager postErrorName:NSLocalizedString(@"Too Many Layers",nil) description:NSLocalizedString(@"Too Many Layer Boolops msg",nil)];
		return;
	}
	// at least 2 objects required:
	
	if([sel count] < 2)
		return;
	
	[self deselectAllShapes];
	while(( obj = [iter nextObject]))
	{	
		// if result path is nil, this is the first object which is the one we'll keep unioning.
		
		// verifier si c'est du texte
		
		if ( rp == nil )
			rp = [obj path];
		else
			rp = [rp pathFromUnionWithPath:[obj path]];
	}
	
	// make a new shape from the result path, inheriting style of the topmost object
	
	result = [[DBBezierCurve alloc] initWithPath:rp];
	[result setStroke:[[[(DBShape *)[sel lastObject] stroke] copy] autorelease] ];
	[result setFills:[[[(DBShape *)[sel lastObject] fills] copy] autorelease] ];
	
	[self replaceShapes:sel byShape:result actionName:@"Union"];
    
	[self deselectAllShapes];
  	[self selectShape:result];
	[result release];
	[sel release]; 
	[self setNeedsDisplay:YES];
	
//	NSLog(@"present shapes : %@", [[result layer] shapes]);
}



///*********************************************************************************************************************
///
/// method:			diffSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	subtracts the topmost shape from the other.
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			requires exactly two contributing objects. If the shapes don't overlap, this does nothing. The
///					'cutter' object is removed from the layer.
///
///********************************************************************************************************************

- (IBAction)		diffSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [[NSArray alloc] initWithArray:_selectedShapes];
	DBShape*	result;
	
	if([[self selectedShapesLayers] count]>1){
		[_eManager postErrorName:NSLocalizedString(@"Too Many Layers",nil) description:NSLocalizedString(@"Too Many Layer Boolops msg",nil)];
		return;
	}
	if ([sel count] == 2 )
	{
		DBShape		*a, *b;
		NSBezierPath*		rp;
		
		// get the objects in shape form
		
		a = [sel objectAtIndex:0];
		b = [sel objectAtIndex:1];
			
		// form the result
	
		rp = [[a path] pathFromDifferenceWithPath:[b path]];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{
			// if the original was a path, keep it as a path
			
			// if([[sel objectAtIndex:0] isKindOfClass:[DKDrawablePath class]])
			// 	[(DKDrawablePath*)[sel objectAtIndex:0] setPath:rp];
			// else
			// 	[a adoptPath:rp];
			// 
			// [self recordSelectionForUndo];
			// 
			// [self removeObject:[sel objectAtIndex:1]]; // if you wish to leave the "cutter" in the layer, remove this line
			// 
			// [self replaceSelectionWithObject:[sel objectAtIndex:0]];
			// [self commitSelectionUndoWithActionName:NSLocalizedString(@"Difference", @"undo string for diff op")];
	        NSLog(@"elements count %d",[rp elementCount]);
			result = [[DBBezierCurve alloc] initWithPath:rp];
			[result setStroke:[[[(DBShape *)[sel lastObject] stroke] copy] autorelease] ];
			[result setFills:[[[(DBShape *)[sel lastObject] fills] copy] autorelease] ];

			[self replaceShapes:sel byShape:result actionName:@"Diff"];

			[self deselectAllShapes];
		  	[self selectShape:result];
			[result release];
			[sel release];
 			[self setNeedsDisplay:YES];
    	}
	}else{
		[_eManager postErrorName:NSLocalizedString(@"Too Many Objects",nil) description:NSLocalizedString(@"Too Many Objects diff msg",nil)];
	}
}



///*********************************************************************************************************************
///
/// method:			intersectionSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	replaces a pair of objects by their intersection.
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			requires exactly two contributing objects. If the objects don't intersect, does nothing. The result
///					adopts the syle of the topmost contributing object
///
///********************************************************************************************************************

- (IBAction)		intersectionSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [[NSArray alloc] initWithArray:_selectedShapes];
	DBShape*	result;
	
	if([[self selectedShapesLayers] count]>1){
		[_eManager postErrorName:NSLocalizedString(@"Too Many Layers",nil) description:NSLocalizedString(@"Too Many Layer Boolops msg",nil)];
		return;
	}
	if ([sel count] == 2 )
	{
		DBShape		*a, *b;
		NSBezierPath*		rp;
		
		// get the objects in shape form
		
		a = [sel objectAtIndex:0];
		b = [sel objectAtIndex:1];
			
		// form the result
	
		rp = [[a path] pathFromIntersectionWithPath:[b path]];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{	        
			result = [[DBBezierCurve alloc] initWithPath:rp];
			[result setStroke:[[[(DBShape *)[sel lastObject] stroke] copy] autorelease] ];
			[result setFills:[[[(DBShape *)[sel lastObject] fills] copy] autorelease] ];

			[self replaceShapes:sel byShape:result actionName:@"Intersection"];

			[self deselectAllShapes];
		  	[self selectShape:result];
			[result release];
			[sel release];
			[self setNeedsDisplay:YES];
	 	}
	}else{
		[_eManager postErrorName:NSLocalizedString(@"Too Many Objects",nil) description:NSLocalizedString(@"Too Many Objects inter msg",nil)];
	}
}


- (IBAction)		xorSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [[NSArray alloc] initWithArray:_selectedShapes];
	DBShape*	result;
	
	if([[self selectedShapesLayers] count]>1){
		[_eManager postErrorName:NSLocalizedString(@"Too Many Layers",nil) description:NSLocalizedString(@"Too Many Layer Boolops msg",nil)];
		return;
	}
	if ([sel count] == 2 )
	{
		DBShape		*a, *b;
		NSBezierPath*		rp;
		
		// get the objects in shape form
		
		a = [sel objectAtIndex:0];
		b = [sel objectAtIndex:1];
					
		// form the result
	
		rp = [[a path] pathFromExclusiveOrWithPath:[b path]];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{	        
			result = [[DBBezierCurve alloc] initWithPath:rp];
			[result setStroke:[[[(DBShape *)[sel lastObject] stroke] copy] autorelease] ];
			[result setFills:[[[(DBShape *)[sel lastObject] fills] copy] autorelease] ];

			[self replaceShapes:sel byShape:result actionName:@"XOR"];

			[self deselectAllShapes];
		  	[self selectShape:result];
			[result release];
			[sel release];
			
			[self setNeedsDisplay:YES];
	 	}
	}else{
		[_eManager postErrorName:NSLocalizedString(@"Too Many Objects",nil) description:NSLocalizedString(@"Too Many Objects xor msg",nil)];
	}
}
@end
