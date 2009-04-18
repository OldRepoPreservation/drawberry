//
//  DBDrawingView.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

//#include <stdlib.h>

#import "DBDrawingView.h"
#import "DBDrawingView+ShapeManagement.h"
#import "DBDrawingView+Undo.h"
#import "DBDrawingView+BooleanOps.h"


#import "DBDrawingExtensions.h"  

#import "DBWindow.h"


#import "DBDocument.h"
#import "DBLayerController.h"

#import "DBToolsController.h"

#import "DBShape.h"
#import "DBLayer.h"
#import "DBCILayer.h"

#import "DBMagnifyingView.h" 
#import "DBMagnifyingController.h"

#import "DBContextualDataSourceController.h"

#import "EMErrorManager.h"

#import "DBPrefKeys.h"

@class DBCILayer;
@class DBRectangle;

@interface DBDrawingView (Private)
- (void)_drawCanevasBackgroundInRect:(NSRect)rect;
@end
 
@implementation NSObject (toto)
@end

@implementation NSObject (BugTracking)
- (BOOL)isDrawingToScreen
{
	NSLog(@"%@",12);
	return NO;
}
@end

@implementation DBDrawingView

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObject:@"zoom"] triggerChangeNotificationsForDependentKey:@"zoomExponent"];
	[self setKeys:[NSArray arrayWithObject:@"zoom"] triggerChangeNotificationsForDependentKey:@"zoomPercentage"];
	[self setKeys:[NSArray arrayWithObjects:@"zoom",@"canevasSize",nil] triggerChangeNotificationsForDependentKey:@"zoomedCanevasSize"];

	[self exposeBinding:@"selectShape"];
}

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		
/*		_canevasRect.origin = NSZeroPoint;
		_canevasRect = NSMakeSize(400,500);   */
		
//		if([self isMemberOfClass:[DBDrawingView class]]){
			[self setCanevasSize:NSMakeSize(595,841)];
//		}
		
		[self updateFrameOrigin];
		[self updateCanevasOrigin];
				
		[self setBackgroundColor:[NSColor lightGrayColor]];
		[self setGridColor:[NSColor grayColor]];
		[self setCanevasColor:[NSColor whiteColor]]; 
		[self setShowGrid:YES];
		
		[self setGridSpacing:72.0];
		[self setGridTickCount:5];
		
		[self setShowRulers:YES];
		
		[self setZoom:1.0];
						
  
  	_selectedShapes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
	[_selectedShapes release];
	[_horizontalRuler release];
	[_verticalRuler release];
		
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
} 

- (void)awakeFromNib
{
	[[self window] setAcceptsMouseMovedEvents:YES];
	[self updateFrameOrigin];[self updateCanevasOrigin]; 
	
	[[self enclosingScrollView] setRulersVisible:_showRulers];
	
	NSScrollView *enclosingScrollView = [self enclosingScrollView];
	[enclosingScrollView setHasVerticalRuler:YES];
	[enclosingScrollView setHasHorizontalRuler:YES];
	_horizontalRuler = [[enclosingScrollView horizontalRulerView] retain];
	_verticalRuler = [[enclosingScrollView verticalRulerView] retain];
	           
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipViewFrame:) name:NSViewFrameDidChangeNotification object:[[self enclosingScrollView] contentView]];
	
	_eManager = [[EMErrorManager alloc] initWithAttachedView:[self enclosingScrollView] corner:LowerRightCorner offset:NSMakePoint(15,15)];
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor],NSForegroundColorAttributeName,[NSFont userFontOfSize:13], NSFontAttributeName, nil];
	[[_eManager errorView] setTitleAttributes:attributes];
	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor],NSForegroundColorAttributeName,[NSFont userFontOfSize:9.0], NSFontAttributeName, nil];
	[[_eManager errorView] setDescriptionAttributes:attributes];
	
	[[_eManager errorView] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0.9]];

	[[enclosingScrollView horizontalRulerView] setClientView:[self enclosingScrollView]];	
	[[enclosingScrollView verticalRulerView] setClientView:[self enclosingScrollView]];
    
	_mouseHorizRulerMarker = [[NSRulerMarker alloc] initWithRulerView:[enclosingScrollView horizontalRulerView] markerLocation:10.0 image:[NSImage imageNamed:@"HorizRulerKnob"]  imageOrigin:NSMakePoint(6.0,7.0)];
	[[enclosingScrollView horizontalRulerView] addMarker:_mouseHorizRulerMarker];
	_leftHorizRulerMarker = [[NSRulerMarker alloc] initWithRulerView:[enclosingScrollView horizontalRulerView] markerLocation:-256e6 image:[NSImage imageNamed:@"HorizLeftRulerKnob"]  imageOrigin:NSMakePoint(7.0,5.0)];
	[[enclosingScrollView horizontalRulerView] addMarker:_leftHorizRulerMarker];
	_rightHorizRulerMarker = [[NSRulerMarker alloc] initWithRulerView:[enclosingScrollView horizontalRulerView] markerLocation:-256e6 image:[NSImage imageNamed:@"HorizRightRulerKnob"]  imageOrigin:NSMakePoint(7.0,5.0)];
	[[enclosingScrollView horizontalRulerView] addMarker:_rightHorizRulerMarker];
	
	[[enclosingScrollView horizontalRulerView] setReservedThicknessForMarkers:10];

	_mouseVertRulerMarker = [[NSRulerMarker alloc] initWithRulerView:[enclosingScrollView verticalRulerView] markerLocation:10.0 image:[NSImage imageNamed:@"VertRulerKnob"]  imageOrigin:NSMakePoint(5.0,6.0)];
   	[[enclosingScrollView verticalRulerView] addMarker:_mouseVertRulerMarker];  
	_upVertRulerMarker = [[NSRulerMarker alloc] initWithRulerView:[enclosingScrollView verticalRulerView] markerLocation:-256e6 image:[NSImage imageNamed:@"VertUpRulerKnob"]  imageOrigin:NSMakePoint(5.0,7.0)];
   	[[enclosingScrollView verticalRulerView] addMarker:_upVertRulerMarker];  
	_downVertRulerMarker = [[NSRulerMarker alloc] initWithRulerView:[enclosingScrollView verticalRulerView] markerLocation:-256e6 image:[NSImage imageNamed:@"VertDownRulerKnob"]  imageOrigin:NSMakePoint(5.0,7.0)];
   	[[enclosingScrollView verticalRulerView] addMarker:_downVertRulerMarker];  

	[self updateRulerUnits];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType, DBShapePboardType, nil]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitDidChange:) name:DBDidChangeUnitNotificationName object:nil];
	
}   

- (BOOL)isFlipped
{
	return YES;
}              

- (BOOL)isExporting
{
	return _isExporting;
}

- (void)setExporting:(BOOL)newIsExporting
{
	_isExporting = newIsExporting;
}

- (void)drawRect:(NSRect)rect 
{
    // Drawing code here.
	
	[[self backgroundColor] set];
	
	NSRect zoomedCanevasRect;
	
	zoomedCanevasRect = _canevasRect;
	zoomedCanevasRect.size.width *= _zoom; 
	zoomedCanevasRect.size.height *= _zoom; 
	
	if(!NSContainsRect(zoomedCanevasRect,rect))
		[NSBezierPath fillRect:rect];
		
	NSRect intersectionRect;
	
	intersectionRect = NSIntersectionRect(rect, zoomedCanevasRect);
	
	// fill the intersection rect 
	[self _drawCanevasBackgroundInRect:intersectionRect];
	
	// draw the grid  
	if(_showGrid && !_isExporting){
//		DBDrawGridWithPropertiesInRect([self gridSpacing]*_zoom,[self gridTickCount],[self gridColor], zoomedCanevasRect, NSMakePoint(_canevasRect.origin.x+0.5,_canevasRect.origin.y+0.5));
		DBDrawGridWithPropertiesInRect([self gridSpacing]*_zoom,[self gridTickCount],[self gridColor], intersectionRect, NSMakePoint(_canevasRect.origin.x+0.5,_canevasRect.origin.y+0.5));
	}
	
	[NSGraphicsContext saveGraphicsState];
	NSAffineTransform *zoomTrsfm, *translateTrsfm;
	zoomTrsfm = [NSAffineTransform transform];
	translateTrsfm = [NSAffineTransform transform];

	[translateTrsfm translateXBy:_canevasRect.origin.x yBy:_canevasRect.origin.y];
	[zoomTrsfm scaleBy:_zoom];
	
	[translateTrsfm concat];
	[zoomTrsfm concat];
	
	NSRect drawingRect;
	
	drawingRect = rect;
	drawingRect.origin.x -= _canevasRect.origin.x;
	drawingRect.origin.y -= _canevasRect.origin.y;
	drawingRect.origin.x /= [self zoom];
	drawingRect.origin.y /= [self zoom];
	drawingRect.size.width /= [self zoom];
	drawingRect.size.height /= [self zoom];
	
	if([[DBMagnifyingController sharedMagnifyingView] isDrawingSource]){
		[[self layerController] drawDirectlyLayersInRect:drawingRect];
	}else{
		[[self layerController] drawLayersInRect:drawingRect];
	}      
	
	if(!_isExporting){
		[_selectedShapes makeObjectsPerformSelector:@selector(drawBounds)];
		[_selectedShapes makeObjectsPerformSelector:@selector(displaySelectionKnobs)];
		[_editingShape displayEditingKnobs];
	}
//	[_editingShape drawInView:self rect:NSZeroRect];
	
	if(!NSEqualRects(NSZeroRect,_selectionRect)){
		[[NSColor darkGrayColor] set];                                    
		// use offset rect to desactivate anti-aliasing
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSOffsetRect(_selectionRect,0.5,0.5)];
		float dash[2] = {5.0,3.0};
		[path setLineDash:dash count:2 phase:0.0];
	 	[path stroke];
				
		[_selectionRectShapes makeObjectsPerformSelector:@selector(drawBounds)];
		[_selectionRectShapes makeObjectsPerformSelector:@selector(displaySelectionKnobs)];		
	}
	[NSGraphicsContext restoreGraphicsState];


}

- (void)_drawCanevasBackgroundInRect:(NSRect)rect
{
	if(_canevasColor == nil)
	{
		
	}else{
		if(!_isExporting)
			[[self canevasColor] set];                           
		else
			[[NSColor clearColor] set];
			
		[NSBezierPath fillRect:rect];
//		[[NSBezierPath bezierPathWithRect:rect] fill];
	}
}  

- (void)setNeedsDisplay:(BOOL)flag
{
	[super setNeedsDisplay:flag];
	
	if([[DBMagnifyingController sharedMagnifyingView] source] == self && [[[NSApp delegate] magnifyWindow] isVisible]){
 		[[DBMagnifyingController sharedMagnifyingView] setNeedsDisplay:YES];   	
	}
}                                           

- (void)setNeedsDisplayInRect:(NSRect)rect
{
	[super setNeedsDisplayInRect:rect];
	
	if(NSIntersectsRect(rect, [[DBMagnifyingController sharedMagnifyingView] sourceZoomedRect]) && 
		[[DBMagnifyingController sharedMagnifyingView] source] == self &&
		[[[NSApp delegate] magnifyWindow] isVisible]){
		[[DBMagnifyingController sharedMagnifyingView] setNeedsDisplay:YES];
	}
}

#pragma mark -
#pragma mark Accessors
- (NSColor *)backgroundColor
{
	return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)oldBackgroundColor
{
	[oldBackgroundColor retain];
	[_backgroundColor release];
	_backgroundColor = oldBackgroundColor;
	 
	[self setNeedsDisplay:YES]; 
}

- (NSColor *)gridColor
{
	return _gridColor;
}

- (void)setGridColor:(NSColor *)oldGridColor
{
	[oldGridColor retain];
	[_gridColor release];
	_gridColor = oldGridColor; 
	
	[self setNeedsDisplay:YES]; 
}

- (NSColor *)canevasColor
{
	return _canevasColor;
}

- (void)setCanevasColor:(NSColor *)oldCanevasColor
{
	[oldCanevasColor retain];
	[_canevasColor release];
	_canevasColor = oldCanevasColor;
	 
	[self setNeedsDisplay:YES]; 
}
 
- (NSSize)canevasSize
{
	return _canevasRect.size;
}

- (NSSize)zoomedCanevasSize
{
	return NSMakeSize(_canevasRect.size.width*_zoom,_canevasRect.size.height*_zoom);
}   

- (void)setCanevasSize:(NSSize)newCanevasSize
{
	_canevasRect.size = newCanevasSize;
/*	
	NSRect frame = [self frame];
	frame.size = _canevasRect.size;
	[self setFrame:frame];
	                        */
	[self updateFrameOrigin];
    [self updateCanevasOrigin];
	
	[self setNeedsDisplay:YES];
}

- (BOOL)showGrid
{
	return _showGrid;
}

- (void)setShowGrid:(BOOL)newShowGrid
{
	_showGrid = newShowGrid;  
	[self setNeedsDisplay:YES];
}

- (float)gridSpacing
{
	return _gridSpacing;
}

- (void)setGridSpacing:(float)newGridSpacing
{
	_gridSpacing = newGridSpacing;
	[self setNeedsDisplay:YES];
}

- (int)gridTickCount
{
	return _gridTickCount;
}

- (void)setGridTickCount:(int)newGridTickCount
{
	_gridTickCount = newGridTickCount;
	[self setNeedsDisplay:YES];
}

- (BOOL)showRulers
{
	return _showRulers;
}

- (void)setShowRulers:(BOOL)newShowRulers
{
	_showRulers = newShowRulers;
	[[self enclosingScrollView] setRulersVisible:_showRulers];
}

- (float)canevasWidth
{
	return _canevasRect.size.width;
}

- (void)setCanevasWidth:(float)newCanevasWidth
{
	_canevasRect.size.width = newCanevasWidth; 
	[self updateFrameOrigin];
	[self updateCanevasOrigin];
	[self setNeedsDisplay:YES];
}

- (float)canevasHeight
{
	return _canevasRect.size.height;
}

- (void)setCanevasHeight:(float)newCanevasHeight
{
	_canevasRect.size.height = newCanevasHeight;
	[self updateFrameOrigin];
	[self updateCanevasOrigin]; 
   	[self setNeedsDisplay:YES];
}

- (float)zoom
{
	return _zoom;
}

- (void)setZoom:(float)newZoom
{
	if(newZoom != _zoom)
	{
		_zoom = newZoom;
		[self updateFrameOrigin]; 
		[self updateCanevasOrigin]; 
//		[[self layerController] updateLayersAndShapes];
//		[[self layerController] updateShapesBounds];
		[self setNeedsDisplay:YES];
	}
}

- (void)setZoomWithoutDisplay:(float)newZoom 
{
	_zoom = newZoom;
}
 
- (float)zoomExponent
{
	return (log2f(_zoom));
}

- (void)setZoomExponent:(float)newZoomExponent
{
	[self setZoom:pow(2,newZoomExponent)];
}

- (float)zoomPercentage
{
	return _zoom*100;
}

- (void)setZoomPercentage:(float)newZoomPercentage
{
	[self setZoom:newZoomPercentage/100];
}

- (BOOL)snapToGrid
{
	return _snapToGrid;
}

- (void)setSnapToGrid:(BOOL)newSnapToGrid
{
	_snapToGrid = newSnapToGrid;
}

- (EMErrorManager *)errorManager
{
	return _eManager;
}

- (DBLayerController *)layerController
{
	return [_document layerController];
}

#pragma mark -
#pragma mark Events
- (void)mouseMoved:(NSEvent *)theEvent
{
	[self moveMouseRulerMarkerWithEvent:theEvent];
	
	[super mouseMoved:theEvent];
}   

- (void)mouseDown:(NSEvent *)theEvent
{
   	if([[DBToolsController sharedToolsController] selectedTool] == 0){
		[self selectAndTrackMouseWithEvent:theEvent];
	}else{ 
		[self deselectAllShapes];
		 
		Class shapeClass = [[DBToolsController sharedToolsController] shapeClassForSelectedTool]; 

		if (shapeClass) {
	        [self createShapeOfClass:shapeClass withEvent:theEvent];
	    } else {

	    }
	}
    
}

- (void)mouseUp:(NSEvent *)theEvent
{                           
	[super mouseUp:theEvent];
	_draggedShapesCount = 0;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:theEvent];
	
	if(_draggedShapesCount > 0){
		NSPoint point;
		NSImage *image;

		point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
		image = [NSImage imageNamed:@"newShape"];
		[self dragImage:image at:point offset:NSMakeSize(-5,-5) event:theEvent pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard] source:self slideBack:NO];
		
	}
//	[[DBMagnifyingController sharedMagnifyingView] setMagnifyingPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
}   

- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent keyCode] ==  51){
		if(_editingShape){
			[_editingShape delete:self];
		}else{
			[self deleteSelectedShapes];
		}
	
	}else if([theEvent keyCode] >= 123 && [theEvent keyCode] <= 126){
		float dX, dY;
		dX = 0.0 ; dY = 0.0;

		switch([theEvent keyCode]){
			case 123 : dX = -1.0;
				break;
			case 124 : dX= 1.0;
				break;
			case 125 : dY = 1.0;
				break;
			case 126 : dY = -1.0;
				break;
		}
		NSEnumerator *e = [_selectedShapes objectEnumerator];
		DBShape * shape;

		while((shape = [e nextObject])){
			[shape moveByX:dX byY:dY];
		}                             
		
		
		[[self selectedShapesLayers] makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:self];
		[[self layerController] updateDependentLayers:[[self selectedShapesLayers] objectAtIndex:0]];
	    [self setNeedsDisplay:YES];
		NSPoint translactionVector;
		translactionVector.x = -dX;
		translactionVector.y = -dY;
		
		// copy the selected shapes to an NSArray, so the array is not changed during execution
		NSArray *translatedShapes = [_selectedShapes copy];
		[[[_document specialUndoManager] prepareWithInvocationTarget:self] translateShapes:translatedShapes vector:translactionVector]; 
		[[_document specialUndoManager] setActionName:NSLocalizedString(@"Move", nil)];
		[translatedShapes release];
		
	}else if([[theEvent characters] isEqualTo:@"a"]){
		[_editingShape addPoint:self];
	}else if([[theEvent characters] isEqualTo:@"r"]){
	 	[_editingShape replaceInView:self];
	}else if([[theEvent characters] isEqualTo:@"c"]){
		[self convertSelectedShapes];
	}else{
		[super keyDown:theEvent];
	}
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[super flagsChanged:theEvent];
	[self setNeedsDisplay:YES];
} 


- (BOOL)acceptsFirstResponder
{
	return YES;
}

#pragma mark Editing

- (void)createShapeOfClass:(Class)theClass withEvent:(NSEvent *)theEvent 
{
	//NSLog(@"create");
	[[self layerController] beginEditing];
	
	DBLayer *currentLayer;
	DBShape *shape;                                                           
	
	currentLayer = [[self layerController] selectedLayer];
    
   	if([currentLayer isKindOfClass:[DBCILayer class]]){
		[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable CILayer msg",nil)];
	 
		return;
	}else if(![currentLayer editable]){
		[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable Layer msg",nil)];
	 
		return;
	}
 	shape = [[theClass alloc] init];
 	[currentLayer setTempShape:shape];
//	[currentLayer addShape:shape];
	

//	[self startEditingShape:shape];
	_editingShape = shape;

			
	if([shape createWithEvent:theEvent inView:self])
    {
		// select the shape 
		[currentLayer addShape:shape];
		[self selectShape:shape];
		[_dataSourceController updateSelection];
 		
	}else{
//    	[currentLayer removeShape:shape];
	}     
//	[currentLayer setTempShape:nil];
	
	
//	[[self layerController] endEditing];

	
	[currentLayer updateRenderInView:self];
	
	[[self layerController] updateDependentLayers:currentLayer];
	
	
	[self stopEditingShape];
	[shape release];
	
	[self setNeedsDisplay:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DBToolDidCreateShapeNotification object:self];
}

- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent
{
	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	p = [self canevasCoordinatesFromViewCoordinates:p];
   	DBShape *shapeUnderMouse;
	shapeUnderMouse = [[self layerController] hitTest:p];

	
	BOOL isExtendingSelection;
	isExtendingSelection = (([theEvent modifierFlags] & NSShiftKeyMask) ? YES : NO);
    
	// search for knob
	NSEnumerator *e = [_selectedShapes objectEnumerator];
	DBShape * shape;
	int knob = NoKnob;
	
	while((shape = [e nextObject])){
		knob = [shape knobUnderPoint:p];
		
		if(knob != NoKnob){
			break;
		}
	}
	
	//	NSLog(@"shapeUnderMouse %@", shapeUnderMouse);
 
   	if(shapeUnderMouse && knob == NoKnob){
	   	
		if(isExtendingSelection && !_editingShape){    
			DBShape *oldEditingShape = _editingShape;
		
			if(shapeUnderMouse && [_selectedShapes count] == 0)
				[self stopEditingShape];
		
			[self selectShape:oldEditingShape];
			[self toggleSelectShape:shapeUnderMouse];
		}else if(([theEvent modifierFlags] & NSAlternateKeyMask) && !_editingShape){
			if([_selectedShapes containsObject:shapeUnderMouse]){
				[self writeShapes:_selectedShapes toPasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]];
				_draggedShapesCount = [_selectedShapes count];
			}else{
				[self writeShapes:[NSArray arrayWithObject:shapeUnderMouse] toPasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]];
				_draggedShapesCount = 1;
			}
		}else{
			if([theEvent clickCount] == 1){ 			
				if(![_editingShape hitTest:p]){
					if(![_selectedShapes containsObject:shapeUnderMouse]){
						// the selection changes
						
						// test the selected layer knobs
						
						DBLayer *layer;
						layer = [[self layerController] selectedLayer];
						if([layer isKindOfClass:[DBCILayer class]]){
							if([(DBCILayer *)layer moveFilterPoints:theEvent inView:self]){

								return;
							}else{

							}
						}
						
						[self deselectAllShapes];
						[self selectShape:shapeUnderMouse];
	
						if(shapeUnderMouse != _editingShape)
							[self stopEditingShape]; 
				    }else{
					}
 					[self moveSelectedShapesWithEvent:theEvent];
  
				}else{
					BOOL edited;
				
					edited = [_editingShape editWithEvent:theEvent inView:self];
				
				}
			}else if([theEvent clickCount] == 2){        
				[self deselectAllShapes];
				[self startEditingShape:shapeUnderMouse];
			}
		}
	}else{
		
/*		NSEnumerator *e = [_selectedShapes objectEnumerator];
		DBShape * shape;
		int knob = NoKnob;
		
		while((shape = [e nextObject])){
			knob = [shape knobUnderPoint:p];
			
			if(knob != NoKnob){
				break;
			}
		}
*/	  	
		if(! isExtendingSelection){
			[self deselectAllShapes];
			[self stopEditingShape];
			[self selectShape:shape];
			
			if(shape){
				if([theEvent modifierFlags] & NSControlKeyMask)
					[self rotateSelectedShapeWithEvent:theEvent];
				else
					[self resizeSelectedShapeWithEvent:theEvent knob:knob];
				return; 	
			}else{
				// maybe shape under mouse but no knob under mouse so move layer related control points
				
				DBLayer *layer;
				layer = [[self layerController] selectedLayer];
				
				if([layer isKindOfClass:[DBCILayer class]]){
				
					[(DBCILayer *)layer moveFilterPoints:theEvent inView:self];
					return;
				}
			}
			
	   	}else{
			[self toggleSelectShape:shape];
	   	}
	
		[self selectRectWithEvent:theEvent];
	}
	
	      
}

- (void)selectRectWithEvent:(NSEvent *)theEvent
{
	NSPoint originLoc, currentLoc, p;
	
	_selectionRect = NSZeroRect;
	_selectionRectShapes = nil;
	
	originLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	originLoc = [self canevasCoordinatesFromViewCoordinates:originLoc];
	currentLoc = originLoc;

	[self moveHorizMouseRulerMarkerToLocation:-256e6];
	[self moveVertMouseRulerMarkerToLocation:-256e6];
	
	while(YES){
		theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        currentLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        currentLoc = [self canevasCoordinatesFromViewCoordinates:currentLoc];
		NSRect newSelectionRect;
		
		newSelectionRect = DBRectWithPoints(originLoc, currentLoc);
		
		_selectionRect = newSelectionRect;
		_selectionRectShapes = [[self shapesInRect:_selectionRect] retain];
		
		p = NSMakePoint(NSMinX(_selectionRect),NSMinY(_selectionRect));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setLeftMarkerLocation:p.x];
		[self setUpMarkerLocation:p.y];

		p = NSMakePoint(NSMaxX(_selectionRect),NSMaxY(_selectionRect));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setRightMarkerLocation:p.x];
		[self setDownMarkerLocation:p.y];
		
		[self setNeedsDisplay:YES];

//		[[DBMagnifyingController sharedMagnifyingView] setMagnifyingPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
		
		if([theEvent type] == NSLeftMouseUp){
			break;
		}
	} 
	      
	[self setLeftMarkerLocation:-256e6];
	[self setUpMarkerLocation:-256e6];
   	[self setRightMarkerLocation:-256e6];
	[self setDownMarkerLocation:-256e6];
	
	[self moveMouseRulerMarkerWithEvent:theEvent];

	NSEnumerator *e = [_selectionRectShapes objectEnumerator];
	DBShape * shape;

	[self willChangeValueForKey:@"selectedShape"];	

	while((shape = [e nextObject])){
		if(![_selectedShapes containsObject:shape])
			[_selectedShapes addObject:shape];
	}
	
	[self didChangeValueForKey:@"selectedShape"];	
	
	[_selectionRectShapes release];
	_selectionRectShapes = nil;
	_selectionRect = NSZeroRect;
	
	[_dataSourceController performSelector:@selector(updateSelection) withObject:nil afterDelay:FLT_MIN];
	
}

- (void)moveSelectedShapesWithEvent:(NSEvent *)theEvent 
{
	
	NSPoint currentLoc, previousLoc, originOffset, upleftCorner, p;
	NSPoint originLoc, translactionVector;
	float deltaX, deltaY;
	NSRect enclosingRect;
	BOOL didMove;
	BOOL isEditable;
	NSAutoreleasePool *pool;

	NSEnumerator *e;
	DBShape *shape;
	 
	enclosingRect = [DBShape enclosingRectForShapes:_selectedShapes];
	
//	[self deselectAllShapes];
//	[self selectShape:[_selectedShapes objectAtIndex:0]];
    
	[[self layerController] selectLayer:[[self selectedShape] layer]];
	
	previousLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	upleftCorner = [[_selectedShapes objectAtIndex:0] pointForKnob:UpperLeftKnob];
	previousLoc = [self canevasCoordinatesFromViewCoordinates:previousLoc];

	originOffset = NSMakePoint(previousLoc.x - upleftCorner.x, previousLoc.y - upleftCorner.y);

	originLoc = previousLoc;
//	upleftCorner = [self canevasCoordinatesFromViewCoordinates:upleftCorner];
	
	didMove = NO;
	isEditable = YES;
	
   	e = [[self selectedShapesLayers] objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject]) && isEditable){
		isEditable = [layer editable];
	}        
	
   	
	while(YES){

  	 	pool = [[NSAutoreleasePool alloc] init];
  	 		
		theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];

	   	currentLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
		currentLoc = [self canevasCoordinatesFromViewCoordinates:currentLoc];

		currentLoc.x -= originOffset.x;
		currentLoc.y -= originOffset.y;
		currentLoc = [self pointSnapedToGrid:currentLoc];
		currentLoc.x += originOffset.x;
		currentLoc.y += originOffset.y;
		
		
		deltaX = currentLoc.x - previousLoc.x;
		deltaY = currentLoc.y - previousLoc.y;
		
		e = [_selectedShapes objectEnumerator];
	   
	 	if(!isEditable){
			[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable Layer msg",nil)];
			[pool release];
			break;
	 	}
		if (!NSEqualPoints(previousLoc, currentLoc)){
			[[self layerController] beginEditing];
			while((shape = [e nextObject])){
				[shape moveByX:deltaX byY:deltaY];
			}
			didMove = YES;
			enclosingRect.origin.x += deltaX/**_zoom*/;
			enclosingRect.origin.y += deltaY/**_zoom*/;
//			[[self selectedShapesLayers] makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:self];
			[self setNeedsDisplay:YES];	
		}
		
		[[self layerController] updateDependentLayers:[[self selectedShapesLayers] objectAtIndex:0]];
		
		p = NSMakePoint(NSMinX(enclosingRect),NSMinY(enclosingRect));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setLeftMarkerLocation:p.x];
		[self setUpMarkerLocation:p.y];

		p = NSMakePoint(NSMaxX(enclosingRect),NSMaxY(enclosingRect));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setRightMarkerLocation:p.x];
		[self setDownMarkerLocation:p.y];
		
		p = NSMakePoint(NSMinX(enclosingRect)+NSWidth(enclosingRect)/2.0,NSMinY(enclosingRect)+NSHeight(enclosingRect)/2.0);
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self moveHorizMouseRulerMarkerToLocation:p.x];
		[self moveVertMouseRulerMarkerToLocation:p.y];
		
		
 		previousLoc = currentLoc;
		
	 	[pool release];

		if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
	}
	
	  
	if(didMove){
		[[self layerController] endEditing];
		
		[[self selectedShapesLayers] makeObjectsPerformSelector:@selector(updateRenderInView:) withObject:self];
		[[self layerController] updateDependentLayers:[[self selectedShapesLayers] objectAtIndex:0]];
	
		translactionVector.x = originLoc.x - currentLoc.x;
		translactionVector.y = originLoc.y - currentLoc.y;
		
		// copy the selected shapes to an NSArray, so the array is not changed during execution
		NSArray *translatedShapes = [_selectedShapes copy];
		[[[_document specialUndoManager] prepareWithInvocationTarget:self] translateShapes:translatedShapes vector:translactionVector]; 
		[[_document specialUndoManager] setActionName:NSLocalizedString(@"Move", nil)];
		[translatedShapes release];
	}
	
	[self setLeftMarkerLocation:-256e6];
	[self setUpMarkerLocation:-256e6];
   	[self setRightMarkerLocation:-256e6];
	[self setDownMarkerLocation:-256e6];
	
	[self moveMouseRulerMarkerWithEvent:theEvent];
	
   	[self setNeedsDisplay:YES];	

}

- (void)resizeSelectedShapeWithEvent:(NSEvent *)theEvent knob:(int)knob
{
   	[[self layerController] beginEditing];
    
   	NSPoint previousLoc, currentLoc, originLoc;
	NSPoint p;
	NSRect shapeBounds;
	DBShape *selectedShape;
	NSAutoreleasePool *pool;
	int originKnob;
	   
	previousLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	previousLoc = [self pointSnapedToGrid:previousLoc];

	previousLoc = [self canevasCoordinatesFromViewCoordinates:previousLoc];

	currentLoc = previousLoc;
	originLoc = currentLoc;
	
	originKnob = knob;
	
	if([_selectedShapes count] > 0)
		selectedShape = [_selectedShapes objectAtIndex:0];
   
 	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		currentLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				
		currentLoc = [self pointSnapedToGrid:currentLoc];
		currentLoc = [self canevasCoordinatesFromViewCoordinates:currentLoc];

		knob = [selectedShape resizeByMovingKnob:knob fromPoint:previousLoc toPoint:currentLoc inView:self modifierFlags:[theEvent modifierFlags]];
		[self setNeedsDisplay:YES];
		previousLoc = currentLoc;
				
		[[self layerController] updateDependentLayers:[selectedShape layer]];
		
		shapeBounds = [selectedShape bounds];
		p = NSMakePoint(NSMinX(shapeBounds),NSMinY(shapeBounds));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setLeftMarkerLocation:p.x];
		[self setUpMarkerLocation:p.y];

		p = NSMakePoint(NSMaxX(shapeBounds),NSMaxY(shapeBounds));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setRightMarkerLocation:p.x];
		[self setDownMarkerLocation:p.y];
		
		p = NSMakePoint(NSMinX(shapeBounds)+NSWidth(shapeBounds)/2.0,NSMinY(shapeBounds)+NSHeight(shapeBounds)/2.0);
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self moveHorizMouseRulerMarkerToLocation:p.x+24.0];
		[self moveVertMouseRulerMarkerToLocation:p.y];
		
		[pool release];
		
		if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
	}    
	
	[[self layerController] endEditing];

	[self setLeftMarkerLocation:-256e6];
	[self setUpMarkerLocation:-256e6];
   	[self setRightMarkerLocation:-256e6];
	[self setDownMarkerLocation:-256e6];
	
	[self moveMouseRulerMarkerWithEvent:theEvent];
	
	[[selectedShape layer] updateRenderInView:self];
	[[self layerController] updateDependentLayers:[selectedShape layer]]; 
	
	[[[_document specialUndoManager] prepareWithInvocationTarget:self] resizeShape:selectedShape withKnob:knob fromPoint:[selectedShape pointForKnob:knob] toPoint:originLoc]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(@"Resize", nil)];
	   
}

- (void)rotateSelectedShapeWithEvent:(NSEvent *)theEvent
{
   	[[self layerController] beginEditing];
	
	NSPoint previousLoc, currentLoc, p;
	DBShape *selectedShape;
	float angle, originRotation;
	NSRect shapeBounds;
	NSAutoreleasePool *pool; 

	previousLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	previousLoc = [self canevasCoordinatesFromViewCoordinates:previousLoc];
	currentLoc = previousLoc;
	
	if([_selectedShapes count] > 0)
		selectedShape = [_selectedShapes objectAtIndex:0];
    
	if(![[selectedShape layer] editable]){
		[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable Layer msg",nil)];
		return;
   	}
	
	originRotation = [selectedShape rotation];
    
 	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		currentLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		currentLoc = [self canevasCoordinatesFromViewCoordinates:currentLoc];
               
		angle = DBAngleBetweenPoints([selectedShape rotationCenter],previousLoc,currentLoc);
		[selectedShape setRotation:[selectedShape rotation]+angle*(180/M_PI)];
		
		[self setNeedsDisplay:YES];
		previousLoc = currentLoc;

		shapeBounds = [selectedShape bounds];
		p = NSMakePoint(NSMinX(shapeBounds),NSMinY(shapeBounds));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setLeftMarkerLocation:p.x];
		[self setUpMarkerLocation:p.y];

		p = NSMakePoint(NSMaxX(shapeBounds),NSMaxY(shapeBounds));
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self setRightMarkerLocation:p.x];
		[self setDownMarkerLocation:p.y];
		
		p = NSMakePoint(NSMinX(shapeBounds)+NSWidth(shapeBounds)/2.0,NSMinY(shapeBounds)+NSHeight(shapeBounds)/2.0);
		p = [self rulerLocationWithPoint:NSMakePoint(p.x*[self zoom], p.y*[self zoom])];
		[self moveHorizMouseRulerMarkerToLocation:p.x+24.0];
		[self moveVertMouseRulerMarkerToLocation:p.y];
		
//		[[selectedShape layer] updateRenderInView:self];
  		
		[selectedShape updateFill];
		
		[[self layerController] updateDependentLayers:[selectedShape layer]];
		[pool release];
		
		if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
	} 
	
	[[self layerController] endEditing];
    
	[self setLeftMarkerLocation:-256e6];
	[self setUpMarkerLocation:-256e6];
   	[self setRightMarkerLocation:-256e6];
	[self setDownMarkerLocation:-256e6];
	
	[self moveMouseRulerMarkerWithEvent:theEvent];

	
	[[selectedShape layer] updateRenderInView:self];	
	[[self layerController] updateDependentLayers:[[self selectedShapesLayers] objectAtIndex:0]];

	[[[_document specialUndoManager] prepareWithInvocationTarget:self] rotateShape:selectedShape withAngle:(originRotation - [selectedShape rotation])]; 
	[[_document specialUndoManager] setActionName:NSLocalizedString(@"Rotate", nil)];
	
}   

#pragma mark Copy, Cut & Paste

- (void)copy:(id)sender
{
	if(_selectedShapes && [_selectedShapes count] > 0)
	{
		[self writeShapes:_selectedShapes toPasteboard:[NSPasteboard generalPasteboard]];
	}
}   

- (void)cut:(id)sender
{
	[self copy:sender];
	[self deleteSelectedShapes];
}   

- (void)paste:(id)sender
{
	NSArray *shapes;
	DBLayer *layer;
	
	shapes = [self shapesFromPasteboard:[NSPasteboard generalPasteboard]];
	layer = [[self layerController] selectedLayer];
	[shapes makeObjectsPerformSelector:@selector(setLayer:) withObject:nil];
	
	if([layer isKindOfClass:[DBCILayer class]]){
		[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable CILayer msg",nil)];		
	}else if(![layer editable]){
		[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable Layer msg",nil)];	
	}else{

		NSEnumerator *e = [shapes objectEnumerator];
		DBShape * shape;

		while((shape = [e nextObject])){
			[shape moveByX:10.0 byY:10.0];
		}

		[layer addShapes:shapes];
		[layer updateRenderInView:self];
	}
	
	[self setNeedsDisplay:YES];

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

#pragma mark Rulers

- (void)moveMouseRulerMarkerWithEvent:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	float loc;
	p = [self convertPoint:p fromView:nil];
	p = [self pointSnapedToGrid:p];
	
	loc = [[[[self enclosingScrollView] horizontalRulerView] clientView]  convertPoint:p fromView:self].x;
	[self moveHorizMouseRulerMarkerToLocation:loc];
	loc = [[[[self enclosingScrollView] verticalRulerView] clientView]  convertPoint:p fromView:self].y;
	[self moveVertMouseRulerMarkerToLocation:loc];	
}

- (void)moveHorizMouseRulerMarkerToLocation:(float)loc
{
	[_mouseHorizRulerMarker setMarkerLocation:loc];
	[[[self enclosingScrollView] horizontalRulerView] setNeedsDisplay:YES];
}

- (void)moveVertMouseRulerMarkerToLocation:(float)loc
{
	[_mouseVertRulerMarker setMarkerLocation:loc];
	[[[self enclosingScrollView] verticalRulerView] setNeedsDisplay:YES];
}

- (void)setRightMarkerLocation:(float)loc
{
	[_rightHorizRulerMarker setMarkerLocation:loc];
	[[[self enclosingScrollView] horizontalRulerView] setNeedsDisplay:YES];
}   

- (void)setLeftMarkerLocation:(float)loc
{
	[_leftHorizRulerMarker setMarkerLocation:loc];
	[[[self enclosingScrollView] horizontalRulerView] setNeedsDisplay:YES];
}   

- (void)setUpMarkerLocation:(float)loc  
{
	[_upVertRulerMarker setMarkerLocation:loc];
	[[[self enclosingScrollView] verticalRulerView] setNeedsDisplay:YES];
}   

- (void)setDownMarkerLocation:(float)loc
{
	[_downVertRulerMarker setMarkerLocation:loc];
	[[[self enclosingScrollView] verticalRulerView] setNeedsDisplay:YES];
}   

- (void)updateRulerUnits
{
	[[[self enclosingScrollView] verticalRulerView] setMeasurementUnits:[DBDocument defaultUnit]];
	[[[self enclosingScrollView] horizontalRulerView] setMeasurementUnits:[DBDocument defaultUnit]];
}

- (void)unitDidChange:(NSNotification *)note
{
	[self updateRulerUnits];
}

#pragma mark Contextual Cursor managment

- (void)resetCursorRects
{
	NSCursor *cursor;    
	
	cursor = [NSCursor crosshairCursor];
	
	[self addCursorRect:[self visibleRect] cursor:cursor];
	[cursor setOnMouseEntered:YES];
}

#pragma mark Selected & Edited Shapes

- (void)startEditingShape:(DBShape *)shape
{
	if(![[shape layer] editable]){
		[_eManager postErrorName:NSLocalizedString(@"Uneditable Layer",nil) description:NSLocalizedString(@"Uneditable Layer msg",nil)];
		_editingShape = nil; 
		[_dataSourceController endEditing];
	}else if([shape canEdit]){
		[[self layerController] beginEditing];
		
		[self willChangeValueForKey:@"selectedShape"];
		_editingShape = shape;
		[[self layerController] selectLayer:[_editingShape layer]];
		[self didChangeValueForKey:@"selectedShape"];
		[_editingShape setIsEditing:YES];
		[_dataSourceController beginEditing];
	}
  	[self setNeedsDisplay:YES];
}

- (void)stopEditingShape
{
	[[self layerController] endEditing];

	if(_editingShape)
		[[self layerController] updateDependentLayers:[_editingShape layer]];

	[self willChangeValueForKey:@"selectedShape"];
	[_editingShape setIsEditing:NO];
	_editingShape = nil;
	[self didChangeValueForKey:@"selectedShape"];
	[self setNeedsDisplay:YES];
	[_dataSourceController endEditing];
}

- (DBShape *)editingShape
{
	return _editingShape;
}                        

- (void)selectShape:(DBShape *)shape
{
	if(![_selectedShapes containsObject:shape] && shape)
	{   
		[self willChangeValueForKey:@"selectedShape"];
		[_selectedShapes addObject:shape];
		[[self layerController] selectLayer:[shape layer]];
 		[self didChangeValueForKey:@"selectedShape"];
                       
		[self selectedShape];
		
   		[self setNeedsDisplay:YES];
		[_dataSourceController updateSelection];
	}
}

- (void)deselectShape:(DBShape *)shape
{
	if([_selectedShapes containsObject:shape])
	{      
		[self willChangeValueForKey:@"selectedShape"];
		[_selectedShapes removeObject:shape];
		[self didChangeValueForKey:@"selectedShape"];
		
		[self setNeedsDisplay:YES];
 		[_dataSourceController updateSelection];
   }
}

- (void)toggleSelectShape:(DBShape *)shape
{
	if(shape){
		[self willChangeValueForKey:@"selectedShape"];
		
		if(![_selectedShapes containsObject:shape])
		{    
			[_selectedShapes addObject:shape];
			[[self layerController] selectLayer:[_editingShape layer]];
		}else{
			[_selectedShapes removeObject:shape];
		}
		
		[self didChangeValueForKey:@"selectedShape"];

		[self setNeedsDisplay:YES]; 
		[_dataSourceController updateSelection];
	}		
}

- (void)deselectAllShapes
{
	[self willChangeValueForKey:@"selectedShape"];
	[_selectedShapes setArray:nil];
	[self didChangeValueForKey:@"selectedShape"];
	[self setNeedsDisplay:YES];
	[_dataSourceController updateSelection];
}

- (BOOL)shapeIsSelected:(DBShape *)shape
{
	return [_selectedShapes containsObject:shape];
}

- (DBShape *)selectedShape
{
	DBShape *shape = nil;
	
  	if(_editingShape){
		shape =  _editingShape;
	}else if([_selectedShapes count] == 1){
		shape = [_selectedShapes objectAtIndex:0];
	}
		
	return shape;
} 

- (NSArray *)selectedShapes
{
	return _selectedShapes;
}

- (NSArray *)selectedShapesLayers
{
	if(_editingShape){
		return [NSArray arrayWithObject:_editingShape];
	}
	
	return [DBLayer layersWithShapes:_selectedShapes];
}

#pragma mark Searching for Shapes
- (NSArray *)allShapes
{
	NSMutableArray *array;
	array = [NSMutableArray array];
	
	NSEnumerator *e = [[[self layerController] layers] objectEnumerator];
	DBLayer * layer;

	while((layer = [e nextObject])){
		[array addObjectsFromArray:[layer shapes]];
	}
	
	return array;
}

- (NSSet *)shapesInRect:(NSRect)rect
{
	NSEnumerator *e = [[self allShapes] objectEnumerator];
	NSMutableSet *set;
	DBShape *shape;
    
	set = [NSMutableSet set];
	
	while((shape = [e nextObject])){
	   	if([shape isInRect:rect]){
			[set addObject:shape];
	    }
	}
	
	return set;
}

#pragma mark Conversions

- (NSPoint)canevasCoordinatesFromViewCoordinates:(NSPoint)point
{
	
	point.x -= _canevasRect.origin.x;
	point.y -= _canevasRect.origin.y;
	
	point.x /= _zoom;
	point.y /= _zoom;
	       
	return point;
}

- (NSPoint)viewCoordinatesFromCanevasCoordinates:(NSPoint)point
{
//	point.x *= _zoom;
//	point.y *= _zoom;
	
//  point.x += _canevasRect.origin.x;
//	point.y += _canevasRect.origin.y;
	
	return point;
}   

- (NSPoint)pointSnapedToGrid:(NSPoint)point
{
	if((_snapToGrid && !([[NSApp currentEvent] modifierFlags] & NSCommandKeyMask) ) 
	|| (!_snapToGrid && ([[NSApp currentEvent] modifierFlags] & NSCommandKeyMask) )){
		point.x = /*_zoom**/(floor(((point.x/*/_zoom*/ - _canevasRect.origin.x) / (_zoom*_gridSpacing/_gridTickCount)) + 0.5) * (_zoom*_gridSpacing/_gridTickCount) + (_canevasRect.origin.x));
    	point.y = /*_zoom**/(floor(((point.y/*/_zoom*/ - _canevasRect.origin.y) / (_zoom*_gridSpacing/_gridTickCount)) + 0.5) * (_zoom*_gridSpacing/_gridTickCount) + (_canevasRect.origin.y));
	}

	return point;
}

- (NSPoint)rulerLocationWithPoint:(NSPoint)point
{
	NSPoint p;
	p.x = [[[[self enclosingScrollView] horizontalRulerView] clientView] convertPoint:point fromView:self].x;
	p.y = [[[[self enclosingScrollView] verticalRulerView] clientView] convertPoint:point fromView:self].y;
	
	return p;
}

- (NSAffineTransform *)appliedTransformation
{
	NSAffineTransform *af = [NSAffineTransform transform];
	NSAffineTransform *scale = [NSAffineTransform transform];
	NSAffineTransform *translate = [NSAffineTransform transform];
	
	[scale scaleBy:_zoom];
	[translate translateXBy:_canevasRect.origin.x yBy:_canevasRect.origin.y];
	
	[af appendTransform:scale];
	[af appendTransform:translate];
	
	return af;
}
#pragma mark Layout Update
// update the canevas origin  
- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
	[self updateCanevasOrigin];      
	[super resizeWithOldSuperviewSize:oldBoundsSize];
}

- (void)updateCanevasOrigin
{
	_canevasRect.origin.x = ([self frame].size.width - _canevasRect.size.width*_zoom)/2;
	_canevasRect.origin.y = ([self frame].size.height - _canevasRect.size.height*_zoom)/2;       
	
	[[[self enclosingScrollView] horizontalRulerView] setOriginOffset:_canevasRect.origin.x];
	[[[self enclosingScrollView] verticalRulerView] setOriginOffset:_canevasRect.origin.y];
	
	[[self layerController] updateLayersAndShapes];
	[[self layerController] updateShapesBounds];
	
	[[self layerController] updateLayersRender];
}  

- (void)updateFrameOrigin
{
	NSSize size;
	NSRect frame;
	
	size = [[[self enclosingScrollView] contentView] frame].size;
	frame = [self frame];

	size.width = MAX(size.width, _canevasRect.size.width*_zoom);    
	size.height = MAX(size.height, _canevasRect.size.height*_zoom);     
 
	frame.size = size; 

	[self setFrame:frame];
	 
	[[self layerController] updateShapesBounds];
	
	[[[self enclosingScrollView] contentView] setNeedsDisplay:YES];
} 

- (NSPoint)canevasOrigin
{
	return _canevasRect.origin;
}

#pragma mark Notifications

- (void)clipViewFrame:(NSNotification *)note
{
//    NSLog(@"frame did change : %@", NSStringFromRect([[[self enclosingScrollView] contentView] frame]));
	[self updateFrameOrigin];
	[self updateCanevasOrigin];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	if([[self window] isKindOfClass:[DBWindow class]])
	{   
		return (![(DBWindow *)[self window] appDidBecomeActive]);
	}
	return NO;
}

@end

NSRect DBRectWithPoints(NSPoint firstPoint, NSPoint secondPoint){
	NSRect rect = NSZeroRect;
	
	rect.origin.x = 	MIN(firstPoint.x,secondPoint.x);
	rect.origin.y = 	MIN(firstPoint.y,secondPoint.y);
	rect.size.width = 	MAX(firstPoint.x,secondPoint.x)-rect.origin.x;
	rect.size.height = 	MAX(firstPoint.y,secondPoint.y)-rect.origin.y;  
	
	
	return rect;
}

float DBAngleBetweenPoints(NSPoint center, NSPoint point1, NSPoint point2){
 	double u1,u2,v1,v2;

	u1 = point1.x - center.x;
	u2 = point1.y - center.y;
	v1 = point2.x - center.x;
	v2 = point2.y - center.y;
	
	double cosTheta, normeU, normeV;
	float theta;
	normeU = sqrt(u1*u1 + u2*u2);
	normeV = sqrt(v1*v1 + v2*v2);
		
   
	cosTheta = u1/normeU;
	theta = acos(cosTheta);
	cosTheta = v1/normeV;
	
	if((u2 < 0 && v2 >= 0) || (v2 < 0 && u2 >= 0))
		theta += acos(cosTheta);
	else
		theta -= acos(cosTheta);
	
	if(u2 >= 0){
		theta = -theta;
	}
	
	return theta;
}    
