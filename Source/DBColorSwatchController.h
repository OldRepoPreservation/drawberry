//
//  DBColorSwatchController.h
//  DrawBerry
//
//  Created by Raphael Bost on 12/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBMatrix.h"

@class DBPopUpButton;

@interface DBColorSwatchController : NSWindowController {
	NSColorList *_list;
	NSMutableArray *_colorLists;
	IBOutlet NSMenu *_menu;
	IBOutlet DBMatrix *_matrix;
	
	IBOutlet NSPanel *_swatchesSheet;
	IBOutlet NSTableView *_swatchesList;
	
	IBOutlet DBPopUpButton *_actionPopUp;
}
+ (id)sharedColorSwatchController;
+ (NSString *) colorListDirectory ;
- (IBAction)addColor:(id)sender;
- (IBAction)changeList:(id)sender;
- (IBAction)addList:(id)sender;
- (IBAction)closeSheet:(id)sender;
- (IBAction)removeList:(id)sender;
@end
