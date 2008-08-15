//
//  DBLayerWindowController.m
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBLayerWindowController.h" 

#import "DBApplicationController.h"
#import "DBLayerController.h"    

#import "GCollapseWindow.h"

static DBLayerWindowController *_sharedLayerWindowController = nil;

@class DBLayer;

@implementation DBLayerWindowController

+ (id)sharedLayerWindowController {
    if (!_sharedLayerWindowController) {
        _sharedLayerWindowController = [[DBLayerWindowController allocWithZone:[self zone]] init];
    }
    return _sharedLayerWindowController;
} 

- (id)init {
    self = [self initWithWindowNibName:@"DBLayers"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBLayers"];
    }
    return self;
} 

- (void)awakeFromNib
{
	[[self window] setFrameAutosaveName:@"layerWindow"];
//	[[self window] setHUDStyle:OHProStyle];

	[_layersArrayController addObserver:self 
							 forKeyPath:@"selectedObjects" 
							    options:NSKeyValueObservingOptionNew 
							    context:nil]; 						

    [_layersTableView registerForDraggedTypes:[NSArray arrayWithObject:@"DBLayerDragType"]];
							
}
 
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[self willChangeValueForKey:@"currentLayer"];
	[self didChangeValueForKey:@"currentLayer"];
}

- (DBLayer *)currentLayer
{
	return [[_layersArrayController selectedObjects] objectAtIndex:0];
}

- (IBAction)raiseSelectedLayer:(id)sender
{
	[[[NSApp delegate] currentLayerController] raiseLayerAtIndex:[_layersArrayController selectionIndex] reversed:YES];
	
}

- (IBAction)lowerSelectedLayer:(id)sender
{
	[[[NSApp delegate] currentLayerController] lowerLayerAtIndex:[_layersArrayController selectionIndex] reversed:YES];
}

- (IBAction)raiseAtTopSelectedLayer:(id)sender
{
	[[[NSApp delegate] currentLayerController] raiseAtTopLayerAtIndex:[_layersArrayController selectionIndex] reversed:YES];
	
}

- (IBAction)lowerAtBottomSelectedLayer:(id)sender
{
	[[[NSApp delegate] currentLayerController] lowerAtBottomLayerAtIndex:[_layersArrayController selectionIndex] reversed:YES];
}

- (IBAction)addCILayer:(id)sender
{
	[[[NSApp delegate] currentLayerController] addCILayer:sender];
	[_layersArrayController rearrangeObjects];
	[_layerPanelDrawer open];
	
	[_layersArrayController setSelectionIndex:0];
} 
 

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:@"DBLayerDragType"] owner:self];
    [pboard setData:data forType:@"DBLayerDragType"];

	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
	if(op == NSTableViewDropOn){
		return NSDragOperationNone;
	}
	
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:@"DBLayerDragType"];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
//    int dragRow = [rowIndexes firstIndex];
 
    // Move the specified row to its new location...
	
	[[[NSApp delegate] currentLayerController] moveRowsAtIndex:[rowIndexes firstIndex] toIndex:row-1 reversed:YES];
	
	
	return YES;
}
@end
