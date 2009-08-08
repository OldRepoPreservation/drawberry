//
//  DBUndoUIController.h
//  DrawBerry
//
//  Created by Raphael Bost on 25/07/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBUndoUIController : NSWindowController {
	IBOutlet NSTableView *_undoTableView;
	
	BOOL _isPerformingSelectionChange;
}
+ (id)sharedUndoUIController;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)clear:(id)sender;
@end
