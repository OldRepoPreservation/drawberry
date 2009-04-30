//
//  DBPrefController.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBPrefController : NSWindowController {
	IBOutlet NSPopUpButton *_toolModeSelector;
	IBOutlet NSPopUpButton *_unitSelector;
	
	IBOutlet NSTableView *_templatesView;
}
+ (id)sharedPrefController;
- (IBAction)changeToolSelectionMode:(id)sender;
- (IBAction)changeUnit:(id)sender;

- (IBAction)addTemplate:(id)sender;
- (IBAction)removeTemplate:(id)sender;
@end
