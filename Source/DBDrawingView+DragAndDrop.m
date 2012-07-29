//
//  DBDrawingView+DragAndDrop.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBDrawingView+DragAndDrop.h"
#import "DBDrawingView+ShapeManagement.h"
//#import "DBFill.h"
//#import "DBDocument.h"
#import "DBShape.h"
#import "DBRectangle.h"


@implementation DBDrawingView (DragAndDrop) 
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{                
	return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	
	NSPoint point = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
	DBShape *shape;
	NSString *type;
	
	type = [[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObjects:NSColorPboardType, DBShapePboardType,NSTIFFPboardType,NSPDFPboardType,
																NSPostScriptPboardType,NSPICTPboardType, NSFilenamesPboardType,DBLayerPboardType, nil]];
	
	if([type isEqualToString:DBShapePboardType]){
		return NSDragOperationCopy;
	}else if([type isEqualToString:NSColorPboardType] || [type isEqualToString:NSPDFPboardType] || [type isEqualToString:NSPICTPboardType] ||
			 [type isEqualToString:NSPostScriptPboardType] || [type isEqualToString:NSTIFFPboardType] || 
			 [type isEqualToString:NSFilenamesPboardType]){
		shape = [[self layerController] hitTest:point];
	
		if(shape){
			return NSDragOperationLink;
		}
		return NSDragOperationCopy;
	}else if([type isEqualToString:DBLayerPboardType]){
        return NSDragOperationCopy;
    }
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPoint point = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
	DBShape *shape;
	NSString *type;
	
	type = [[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObjects:NSColorPboardType, DBShapePboardType,NSTIFFPboardType,NSPDFPboardType,
																NSPostScriptPboardType,NSPICTPboardType, NSFilenamesPboardType, DBLayerPboardType,nil]];

	if([type isEqualToString:DBShapePboardType]){
		NSData *pbData;
		DBLayer *layer;
		NSPoint point;
		NSArray *shapeArray;
		
		pbData = [[sender draggingPasteboard] dataForType:DBShapePboardType];
		shapeArray = [NSKeyedUnarchiver unarchiveObjectWithData:pbData];
	   	
	
		if([[self selectedShapes] count] > 0){
			layer = (DBLayer *)[[[self selectedShapes] objectAtIndex:0] layer];			
		}else if([[[self layerController] layers] count] > 0){
			layer = [[self layerController] layerAtIndex:([[[self layerController] layers] count]-1)];
		}else{
			layer = nil;
		}
		                   
		NSEnumerator *e = [shapeArray objectEnumerator];

		while((shape = [e nextObject])){
			[layer addShape:shape];
			[shape updatePath];
			[shape updateBounds];

			point = [self convertPoint:[sender draggingLocation] fromView:nil];

            [shape moveCorner:5 toPoint:point]; // put the center point of the shape at the drop point
		}
		
		[layer updateRenderInView:self];
		[self setNeedsDisplay:YES];

	}else if([type isEqualToString:NSColorPboardType]){
	shape = [[self layerController] hitTest:point];
	
		if(shape){
			DBFill *fill;
			
			if([shape countOfFills] > 0){
				fill = [[shape fills] lastObject];
			}else {
				fill = [[DBFill alloc] initWithShape:shape];
				[shape addFill:fill];
			}

			[fill setFillColor:[NSColor colorFromPasteboard:[sender draggingPasteboard]] ];
			[fill setFillMode:DBColorFillMode];
		
			return YES;
		}
		return NO;
	}else if([type isEqualToString:NSPDFPboardType] || [type isEqualToString:NSPICTPboardType] ||
			 [type isEqualToString:NSPostScriptPboardType] || [type isEqualToString:NSTIFFPboardType] || 
			 [type isEqualToString:NSFilenamesPboardType]){
		
		
		shape = [[self layerController] hitTest:point];
		
		if(shape){
			DBFill *fill;
			NSImage *image;

			image = [[NSImage alloc] initWithPasteboard:[sender draggingPasteboard]];

			if(image){
				fill = [[DBFill alloc] initWithShape:shape];
				[shape addFill:fill];
				
				[fill setImageFillMode:DBDrawMode];
				[fill setFillImage:image];
				[fill setFillMode:DBImageFillMode];
				
				[image release];
				return YES;

			}else {
				return NO;
			}

			
		}else{
            NSImage *image;
            
			image = [[NSImage alloc] initWithPasteboard:[sender draggingPasteboard]];

            [self dropImage:image atPoint:[self convertPoint:[sender draggingLocation] fromView:nil]];
            [image release];
            return YES;
            
        }
		return NO;		
	}else 	if([type isEqualToString:DBLayerPboardType]){
        DBLayer *layer;
        
        NSData* rowData = [[sender draggingPasteboard] dataForType:DBLayerPboardType];
        NSArray* layers = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        
        [[self layerController] insertLayers:layers atIndexes:[NSIndexSet indexSetWithIndex:0]];
        
        [[self layerController] updateLayersAndShapes];
        [[self layerController] updateShapesBounds];
        
        [[self layerController] updateLayersRender];
        [self setNeedsDisplay:YES];
        
        return YES;

    }
	
	return NO;
}

- (void)dropImage:(NSImage *)image atPoint:(NSPoint)dropPoint
{
    DBRectangle *rectShape;
    NSRect rect;
    
    rect.size = [image size];
    rect.origin = dropPoint;
    rect.origin.x -= rect.size.width / 2;
	rect.origin.y -= rect.size.height / 2;

    rectShape = [[DBRectangle alloc] initWithRect:rect];
	
    
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
    
	[[[self layerController] selectedLayer] addShape:rectShape];

    [rectShape release];

    [[[self layerController] selectedLayer] updateRenderInView:self];
    [self setNeedsDisplay:YES];
}
@end
