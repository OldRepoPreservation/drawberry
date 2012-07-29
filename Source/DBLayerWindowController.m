//
//  DBLayerWindowController.m
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBLayerWindowController.h" 

#import "DBApplicationController.h"
#import "DBLayerController.h"    

#import "GCollapsePanel.h"

static DBLayerWindowController *_sharedLayerWindowController = nil;


NSString *DBLayerIndexesPboardType = @"LayerIndexesPboardType";

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

	[_layersArrayController addObserver:self 
							 forKeyPath:@"selectedObjects" 
							    options:NSKeyValueObservingOptionNew 
							    context:nil]; 		
    
    [_layersTableView registerForDraggedTypes:[NSArray arrayWithObject:DBLayerPboardType]];
    [_layersTableView setDraggingSourceOperationMask:(NSDragOperationCopy|NSDragOperationMove) forLocal:YES];
    [_layersTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
							
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
 
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return nil;
}
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObjects:DBLayerIndexesPboardType,DBLayerPboardType,nil] owner:self];
    [pboard setData:data forType:DBLayerIndexesPboardType];
    data = [NSKeyedArchiver archivedDataWithRootObject:[[_layersArrayController arrangedObjects] objectsAtIndexes:rowIndexes]];
    [pboard setData:data forType:DBLayerPboardType];

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
    NSData* rowData = [pboard dataForType:DBLayerIndexesPboardType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
//    int dragRow = [rowIndexes firstIndex];
 
    // Move the specified row to its new location...
	
	[[[NSApp delegate] currentLayerController] moveRowsAtIndex:[rowIndexes firstIndex] toIndex:row-1 reversed:YES];
	
	
	return YES;
}

- (IBAction)copyLayers:(id)sender
{
 
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[[_layersArrayController arrangedObjects] objectsAtIndexes:[_layersTableView selectedRowIndexes]]];
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:DBLayerPboardType] owner:self];
    [pboard setData:data forType:DBLayerPboardType];
}

- (IBAction)pasteLayers:(id)sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    
    
    NSData* rowData = [pboard dataForType:DBLayerPboardType];
    
    if (rowData) {
        NSArray* layers = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        [layers makeObjectsPerformSelector:@selector(changeToCopiedName)];
        
        [_layersArrayController insertObjects:layers atArrangedObjectIndexes:[_layersArrayController selectionIndexes]];
        
        DBLayerController *lc = [[NSApp delegate] currentLayerController]; 

        [lc updateLayersAndShapes];
        [lc updateShapesBounds];
        [lc updateLayersRender];
        
        [(NSView *)[[NSApp delegate] currentDrawingView] setNeedsDisplay:YES];

    }else{
        NSBeep();
    }

}

- (IBAction)duplicateLayers:(id)sender
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[[_layersArrayController arrangedObjects] objectsAtIndexes:[_layersTableView selectedRowIndexes]]];
    
    NSArray* layers = [NSKeyedUnarchiver unarchiveObjectWithData:data]; // to perform deep copy
    [layers makeObjectsPerformSelector:@selector(changeToCopiedName)];
    
    [_layersArrayController insertObjects:layers atArrangedObjectIndexes:[_layersArrayController selectionIndexes]];
    
    DBLayerController *lc = [[NSApp delegate] currentLayerController]; 
    
    [lc updateLayersAndShapes];
    [lc updateShapesBounds];
    [lc updateLayersRender];
    
    [(NSView *)[[NSApp delegate] currentDrawingView] setNeedsDisplay:YES];
    
}
@end
