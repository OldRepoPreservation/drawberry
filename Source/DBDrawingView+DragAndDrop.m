//
//  DBDrawingView+DragAndDrop.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingView+DragAndDrop.h"
#import "DBDrawingView+ShapeManagement.h"
//#import "DBFill.h"
//#import "DBDocument.h"
#import "DBShape.h"


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
																NSPostScriptPboardType,NSPICTPboardType, NSFilenamesPboardType, nil]];
	
	if([type isEqualToString:DBShapePboardType]){
		return NSDragOperationCopy;
	}else if([type isEqualToString:NSColorPboardType] || [type isEqualToString:NSPDFPboardType] || [type isEqualToString:NSPICTPboardType] ||
			 [type isEqualToString:NSPostScriptPboardType] || [type isEqualToString:NSTIFFPboardType] || 
			 [type isEqualToString:NSFilenamesPboardType]){
		shape = [[self layerController] hitTest:point];
	
		if(shape){
			return NSDragOperationLink;
		}
		return NSDragOperationNone;
	}
	return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSLog(@"perform");
	NSPoint point = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
	DBShape *shape;
	NSString *type;
	
	type = [[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObjects:NSColorPboardType, DBShapePboardType,NSTIFFPboardType,NSPDFPboardType,
																NSPostScriptPboardType,NSPICTPboardType, NSFilenamesPboardType, nil]];

	if([type isEqualToString:DBShapePboardType]){
		NSData *pbData;
		DBLayer *layer;
		NSPoint point;
		NSArray *shapeArray;
		
		pbData = [[sender draggingPasteboard] dataForType:DBShapePboardType];
		shapeArray = [NSKeyedUnarchiver unarchiveObjectWithData:pbData];
	   	
	
		if([[self selectedShapes] count] > 0){
			layer = [[[self selectedShapes] objectAtIndex:0] layer];			
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
			point.x -= [shape bounds].size.width /2;
			point.y -= [shape bounds].size.height /2;
			[shape moveByX:point.x byY:point.y];			
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

			
		}
		return NO;		
	}
	
	return NO;
}
@end
