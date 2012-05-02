//
//  DBGroup.m
//  DrawBerry
//
//  Created by Raphael Bost on 29/04/12.
//  Copyright 2012 Ecole Polytechnique. All rights reserved.
//

#import "DBGroup.h"


@implementation DBGroup
- (id)init
{
    return [self initWithName:NSLocalizedString(@"Group", nil)];
}

- (id)initWithName:(NSString *)aName
{
    self = [super init];
    if (self) {
        [self setName:aName];
        
        _shapes = [[NSMutableArray alloc] init];
    }
    
    return self;
}
- (void)dealloc
{
    [_name release];

    [self setShapes:nil];
    [_shapes release];
    
    [super dealloc];
}

- (NSString *)name
{
    return _name;
}
- (void)setName:(NSString *)aName
{
    DBUndoManager *undo = [_groupController documentUndoManager];
	[(DBLayer *)[undo prepareWithInvocationTarget:self] setName:[self name]];
	[undo setActionName:NSLocalizedString(@"Change Group Name", nil)];		

    [aName retain];
    [_name release];
    _name = aName;
}


- (DBGroupController *)groupController
{
    return _groupController;
}
- (void)setGroupController:(DBGroupController *)gpCtrl
{
    _groupController = gpCtrl;
}

- (void)addShape:(DBShape *)aShape
{
	[_shapes addObject:aShape];
	[aShape setGroup:self]; 
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
	
	[aShape setGroup:self];
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
    DBShape *aShape = [_shapes objectAtIndex:i];
    if([aShape group] == self){
        [aShape setGroup:nil];
    }
	[_shapes removeObjectAtIndex:i];
}

- (void)removeShape:(DBShape *)aShape
{
    if([aShape group] == self){
        [aShape setGroup:nil];
    }
	[_shapes removeObject:aShape];
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
    [_shapes makeObjectsPerformSelector:@selector(setGroup:) withObject:nil];

	[_shapes setArray:[NSMutableArray arrayWithArray:newShapes]];
	[_shapes makeObjectsPerformSelector:@selector(setGroup:) withObject:self];
}


- (NSRect)enclosingRect
{
    NSRect bounds = NSZeroRect;
    
    for (DBShape *shape in _shapes) {
        bounds = NSUnionRect(bounds, [shape bounds]);
    }
    
    return bounds;
}


- (void)displayEnclosingRect
{
    [NSGraphicsContext saveGraphicsState];
    
	float dash[2] = {5.0,5.0};                                   
   	[[NSColor blackColor] set];
    
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self enclosingRect]];
	[path setLineWidth:0.5];                            
	[path setLineDash:dash count:2 phase:0.0];
	[path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)displaySelectionKnobs
{
	NSPoint upLeft, bottomLeft, bottomRight, upRight;
	NSPoint midLeft, midRight, midUp, midBottom;
    
    NSRect bounds = [self enclosingRect];
    
	upLeft = NSMakePoint(NSMinX(bounds),NSMinY(bounds));
	bottomLeft = NSMakePoint(NSMaxX(bounds),NSMinY(bounds));
	bottomRight = NSMakePoint(NSMaxX(bounds),NSMaxY(bounds));
	upRight = NSMakePoint(NSMinX(bounds),NSMaxY(bounds));
	
	midLeft = NSMakePoint(NSMinX(bounds),NSMinY(bounds)+NSHeight(bounds)/2);
	midRight = NSMakePoint(NSMaxX(bounds),NSMinY(bounds)+NSHeight(bounds)/2);
	midUp = NSMakePoint(NSMinX(bounds)+NSWidth(bounds)/2,NSMinY(bounds));
	midBottom = NSMakePoint(NSMinX(bounds)+NSWidth(bounds)/2,NSMaxY(bounds));
	
	// draw knobs
		
	if([[NSApp currentEvent] modifierFlags] & NSControlKeyMask){
		[DBShape drawOrangeKnobAtPoint:upLeft];
		[DBShape drawOrangeKnobAtPoint:bottomLeft];
		[DBShape drawOrangeKnobAtPoint:upRight];
		[DBShape drawOrangeKnobAtPoint:bottomRight];
		
		[DBShape drawOrangeKnobAtPoint:midLeft];
		[DBShape drawOrangeKnobAtPoint:midRight];
		[DBShape drawOrangeKnobAtPoint:midUp];
		[DBShape drawOrangeKnobAtPoint:midBottom];
	}else{
		[DBShape drawBlueKnobAtPoint:upLeft];
		[DBShape drawBlueKnobAtPoint:bottomLeft];
		[DBShape drawBlueKnobAtPoint:upRight];
		[DBShape drawBlueKnobAtPoint:bottomRight];
		
		[DBShape drawBlueKnobAtPoint:midLeft];
		[DBShape drawBlueKnobAtPoint:midRight];
		[DBShape drawBlueKnobAtPoint:midUp];
		[DBShape drawBlueKnobAtPoint:midBottom];
	}
}

- (NSArray *)shapeLayers
{
    NSMutableSet *layers = [NSMutableSet set];
    for (DBShape *shape in _shapes) {
        if([shape layer])
            [layers addObject:[shape layer]];
    }
    
    return [layers allObjects];
}

#pragma mark Action application to the group's shapes


- (int)knobUnderPoint:(NSPoint)point
{
    NSRect bounds = [self enclosingRect];
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(bounds),NSMinY(bounds)) ) )
    {
		return UpperLeftKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMaxX(bounds),NSMinY(bounds)) ) )
    {
		return  UpperRightKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMaxX(bounds),NSMaxY(bounds)) ) )
    {
		return LowerRightKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(bounds),NSMaxY(bounds)) ) )
    {
		return LowerLeftKnob;
    } 
    
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(bounds),NSMinY(bounds)+NSHeight(bounds)/2) ) )
    {
		return MiddleLeftKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMaxX(bounds),NSMinY(bounds)+NSHeight(bounds)/2) ) )
    {
		return MiddleRightKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(bounds)+NSWidth(bounds)/2,NSMinY(bounds)) ) )
    {
		return UpperMiddleKnob;
    }
	if( DBPointIsOnKnobAtPoint(point ,NSMakePoint(NSMinX(bounds)+NSWidth(bounds)/2,NSMaxY(bounds)) ) )
    {
		return LowerMiddleKnob;
    }
    
	return NoKnob;
}

- (NSPoint)pointForKnob:(int)knob
{
    NSRect bounds = [self enclosingRect];

	if(knob == UpperLeftKnob)
    {
		return NSMakePoint(NSMinX(bounds),NSMinY(bounds));
    }
	if(knob == UpperRightKnob)
    {
		return NSMakePoint(NSMaxX(bounds),NSMinY(bounds));
    }
	if(knob == LowerRightKnob)
    {
		return NSMakePoint(NSMaxX(bounds),NSMaxY(bounds));
    }
	if(knob == LowerLeftKnob)
    {
		return NSMakePoint(NSMinX(bounds),NSMaxY(bounds));
    } 
    
	if(knob == MiddleLeftKnob)
    {
		return NSMakePoint(NSMinX(bounds),NSMinY(bounds)+NSHeight(bounds)/2);
    }
	if(knob == MiddleRightKnob)
    {
		return NSMakePoint(NSMaxX(bounds),NSMinY(bounds)+NSHeight(bounds)/2);
    }
	if(knob == UpperMiddleKnob)
    {
		return NSMakePoint(NSMinX(bounds)+NSWidth(bounds)/2,NSMinY(bounds));
    }
	if(knob == LowerMiddleKnob)
    {
		return NSMakePoint(NSMinX(bounds)+NSWidth(bounds)/2,NSMaxY(bounds));
    }
	
	return NSMakePoint(NSNotFound,NSNotFound);	
}   

- (void)moveGroupByX:(float)deltaX byY:(float)deltaY
{
    for (DBShape *shape in _shapes) {
        [shape moveByX:deltaX byY:deltaY];
    }

}

- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags
{
    NSRect bounds = [self enclosingRect];
   	if(flags & NSAlternateKeyMask){
		float dX, dY, ratio;
		dX = point.x - fromPoint.x;
		dY = point.y - fromPoint.y;
		ratio = bounds.size.width/ bounds.size.height;
        
		float dX2, dY2;
		dY2 = (bounds.size.width+dX)/ratio - bounds.size.height;
		dX2 = ratio*(bounds.size.height+dY) - bounds.size.width;
		
		if((fabs(dX) < fabs(dY) || (knob == MiddleLeftKnob) || (knob == MiddleRightKnob) ) && (knob != LowerMiddleKnob) && (knob != UpperMiddleKnob) ){
			dY = dY2;
		}else{
			dX = dX2;
   		}
		point.x = fromPoint.x + dX;
		point.y = fromPoint.y + dY;
        
		if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob) || (knob == UpperMiddleKnob)) {
	        // Adjust left edge
			bounds.size.width -= dX;  
	    	bounds.origin.x += dX;
	    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob) || (knob == LowerMiddleKnob)) {
			// Adjust right edge
			bounds.size.width += dX;  
	    }
	    
		if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob) || (knob == MiddleLeftKnob)) {
	        // Adjust top edge
			bounds.size.height -= dY;
	    	bounds.origin.y += dY;
	    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob) || (knob == MiddleRightKnob)) {
	        // Adjust bottom edge
			bounds.size.height += dY;
	    }
        
		if (bounds.size.width < 0.0) {
			knob = [DBShape flipKnob:knob horizontal:YES];
	        bounds.size.width = -bounds.size.width;
	        bounds.origin.x -= bounds.size.width;
            
	     	[self flipVerticallyWithNewKnob:knob];
            
	    }
	    if (bounds.size.height < 0.0) { 
	        knob = [DBShape flipKnob:knob horizontal:NO];
	        bounds.size.height = -bounds.size.height;
	        bounds.origin.y -= bounds.size.height;
	     	[self flipHorizontalyWithNewKnob:knob];
	    } 
	    
   	}
  	else
	{
		if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob)) {
	        // Adjust left edge
			bounds.size.width = NSMaxX(bounds) - point.x;
	    	bounds.origin.x = point.x;
	    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob)) {
			// Adjust right edge
			bounds.size.width = point.x - bounds.origin.x;  
	    }
	    if (bounds.size.width < 0.0) {
			knob = [DBShape flipKnob:knob horizontal:YES];
	        bounds.size.width = -bounds.size.width;
	        bounds.origin.x -= bounds.size.width;
            
	     	[self flipVerticallyWithNewKnob:knob];
            
	    }
        
	    if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob)) {
	        // Adjust top edge
	        bounds.size.height = NSMaxY(bounds) - point.y;
	        bounds.origin.y = point.y;
	    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob)) {
	        // Adjust bottom edge
	        bounds.size.height = point.y - bounds.origin.y;
	    }
	    if (bounds.size.height < 0.0) { 
	        knob = [DBShape flipKnob:knob horizontal:NO];
	        bounds.size.height = -bounds.size.height;
	        bounds.origin.y -= bounds.size.height;
	     	[self flipHorizontalyWithNewKnob:knob];
	    } 
    }
	
	if(isnan(bounds.origin.x)){
		bounds.origin.x = 0;
	}
	if(isnan(bounds.origin.y)){
		bounds.origin.y = 0;
	}
	if(isnan(bounds.size.width)){
		bounds.size.width = 0;
	}
	if(isnan(bounds.size.height)){
		bounds.size.height = 0;
	}
    
    [self putPathInRect:bounds];
    
    return knob; 
}

- (void)flipVerticallyWithNewKnob:(int)knob
{
    for (DBShape *shape in _shapes) {
        [shape flipVerticallyWithNewKnob:knob];
    }

}

- (void)flipHorizontalyWithNewKnob:(int)knob
{
    for (DBShape *shape in _shapes) {
        [shape flipHorizontalyWithNewKnob:knob];
    }

}

- (void)putPathInRect:(NSRect)newRect
{
    NSRect oldRect = [self enclosingRect];
    for (DBShape *shape in _shapes) {
        NSRect newBounds = DBNewRectWhenResizing([shape bounds],oldRect,newRect);
        [shape putPathInRect:newBounds];
    }
 
}
@end

NSRect DBNewRectWhenResizing(NSRect originalRect,NSRect originalContainer, NSRect newContainer)
{
    NSRect bounds = originalRect;
    
    bounds.origin.x -= originalContainer.origin.x;
    bounds.origin.y -= originalContainer.origin.y;
    
	float xFactor, yFactor;

	xFactor = newContainer.size.width / originalContainer.size.width; 
	yFactor = newContainer.size.height / originalContainer.size.height;
    
    bounds.origin.x *= xFactor;
    bounds.origin.y *= yFactor;
    bounds.size.width *= xFactor;
    bounds.size.height *= yFactor;
    
    
    bounds.origin.x += newContainer.origin.x;
    bounds.origin.y += newContainer.origin.y;

    return bounds;
}
