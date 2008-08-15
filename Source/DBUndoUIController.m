//
//  DBUndoUIController.m
//  DrawBerry
//
//  Created by Raphael Bost on 25/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBUndoUIController.h"

#import "DBApplicationController.h"
#import "DBUndoManager.h"
#import "DBUndoObject.h"


static DBUndoUIController *_sharedUndoUIController = nil;

@implementation DBUndoUIController
+ (id)sharedUndoUIController
{
    if (!_sharedUndoUIController) {
        _sharedUndoUIController = [[DBUndoUIController allocWithZone:[self zone]] init];
    }
    return _sharedUndoUIController;
}

- (id)init 
{
    self = [self initWithWindowNibName:@"DBUndo"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBUndo"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
        										 selector:@selector(currentDocumentDidChange:) 
													 name:DBCurrentDocumentDidChange 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
	       										 selector:@selector(managerDidUndoRedo:) 
													 name:DBUndoManagerDidUndoChangeNotification 
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
		      										 selector:@selector(managerDidUndoRedo:) 
													 name:DBUndoManagerDidRedoChangeNotification 
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
		      										 selector:@selector(actionsDidChange:) 
													 name:DBUndoManagerUndoActionsDidChange 
												   object:nil];
    }
    return self;
} 

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)currentDocumentDidChange:(NSNotification *)note
{          
	[_undoTableView reloadData];
}

- (void)actionsDidChange:(NSNotification *)note
{
//	NSLog(@"action changes");
	[_undoTableView reloadData];
	
	DBUndoManager *undoMngr = [[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager]; 
	
	if(!_isPerformingSelectionChange)
   		[_undoTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([undoMngr undoCount])] byExtendingSelection:NO];	
}

- (void)managerDidUndoRedo:(NSNotification *)note
{
//	NSLog(@"undo or redo changes");
	[_undoTableView reloadData];

	DBUndoManager *undoMngr = [[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager]; 
	
	if(!_isPerformingSelectionChange)
		[_undoTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([undoMngr undoCount])] byExtendingSelection:NO];	
	
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{

	DBUndoManager *undoMngr = [[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager]; 
	
	if(!undoMngr){
		return 0;
	}
	return [undoMngr undoCount] + [undoMngr redoCount] + 1;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)row
{
	DBUndoManager *undoMngr = [[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager]; 
	id value;
	if(row == 0){
		return NSLocalizedString(@"Base Image", nil);
	}else{
		row--;
	}
	
	if(row >= 0 && row < [undoMngr undoCount]){
		// the row correspond to an undo object
				
		value = [[undoMngr undoObjectAtIndex:row] actionName];
	}else{
		// the row correspond to a redo object
		row -= [undoMngr undoCount];
		row = ([undoMngr redoCount] -1 - row);
		
		value = [[undoMngr redoObjectAtIndex:row] actionName];
	}
	return value;
} 

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	int diff;
	diff = (rowIndex - [_undoTableView selectedRow]);
		
	if(diff == 0){
		return YES;
	}
	
	_isPerformingSelectionChange = YES;
	int i;
	DBUndoManager *undoMngr = [[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager]; 
	
	if(diff < 0){
		// should undo -diff times
		for( i = diff; i < 0; i++ )
		{
			[undoMngr undo];
		}
	}else{
		// should redo diff times
		for( i = 0; i < diff; i++ )
		{
			[undoMngr redo];
		}
	} 
	_isPerformingSelectionChange = NO;
	
	return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return NO;
}

- (IBAction)undo:(id)sender
{
	[[[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager] undo];
}

- (IBAction)redo:(id)sender
{
	[[[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager] redo];
}

- (IBAction)clear:(id)sender
{
	[[[[NSDocumentController sharedDocumentController] currentDocument] specialUndoManager] removeAllActions];
}
@end
