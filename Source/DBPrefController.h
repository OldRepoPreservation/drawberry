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
}
+ (id)sharedPrefController;
- (IBAction)changeToolSelectionMode:(id)sender;
@end
