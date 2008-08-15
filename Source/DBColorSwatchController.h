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
	IBOutlet NSMenu *_menu;
	IBOutlet DBMatrix *_matrix;
	
	IBOutlet DBPopUpButton *_actionPopUp;
}
+ (id)sharedColorSwatchController;
+ (NSString *) colorListDirectory ;
- (IBAction)addColor:(id)sender;
- (IBAction)changeList:(id)sender;
@end
