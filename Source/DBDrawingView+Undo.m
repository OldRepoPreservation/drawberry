//
//  DBDrawingView+Undo.m
//  DrawBerry
//
//  Created by Raphael Bost on 24/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingView+Undo.h"

#import "DBShape.h"
#import "DBUndoManager.h"

NSPoint DBInvertVector(NSPoint vect)
{
	return NSMakePoint(-vect.x, -vect.y);
}
@implementation DBDrawingView (Undo)
- (void)translateShapes:(NSArray *)shapes vector:(NSPoint)vector
{         
    NSEnumerator *e = [shapes objectEnumerator];
	NSArray *layers;
    DBShape * shape;

    while((shape = [e nextObject])){
		[shape moveByX:vector.x byY:vector.y];
    }
    
	layers = [DBLayer layersWithShapes:shapes];
	
	if ([shapes count] == 0 || [layers count] == 0) {
		NSLog(@"error, no shape or no layer");
		return;
	}
	[layers makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:self];
	[[self layerController] updateDependentLayers:[layers objectAtIndex:0]];
	
	[[[_document specialUndoManager] prepareWithInvocationTarget:self] translateShapes:shapes vector:DBInvertVector(vector)]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(@"Move", nil)];
	
	[self setNeedsDisplay:YES];
}

- (void)resizeShape:(DBShape *)shape withKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point
{
	knob = [shape resizeByMovingKnob:knob fromPoint:fromPoint toPoint:point inView:self modifierFlags:0];
	
	[[shape layer] updateRenderInView:self];
	[[self layerController] updateDependentLayers:[shape layer]];
	
	[[[_document specialUndoManager] prepareWithInvocationTarget:self] resizeShape:shape withKnob:knob fromPoint:point toPoint:fromPoint]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(@"Resize", nil)];
		
	[self setNeedsDisplay:YES];
	
}

- (void)rotateShape:(DBShape *)shape withAngle:(float)angle
{
	[shape setRotation:[shape rotation]+angle];
	[shape updatePath];
	[shape updateBounds];
	[shape updateFill];

	
	[[shape layer] updateRenderInView:self];
	[[self layerController] updateDependentLayers:[shape layer]];
	
	[[[_document specialUndoManager] prepareWithInvocationTarget:self] rotateShape:shape withAngle:-angle]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(@"Rotate", nil)];
	
	[self setNeedsDisplay:YES];
}
@end
