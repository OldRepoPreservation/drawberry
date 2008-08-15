//
//  DBToolsController.h
//  DrawBerry
//
//  Created by Raphael Bost on 15/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *DBSelectedToolDidChangeNotification;
extern NSString *DBToolDidCreateShapeNotification;

@interface DBToolsController : NSWindowController {
	IBOutlet	NSMatrix *_toolButtons;
	IBOutlet    NSMatrix *_inspectorSelector;
}
+ (id)sharedToolsController;
- (IBAction)selectToolAction:(id)sender;
- (IBAction)inspectorSelectorAction:(id)sender; 

- (int)selectedTool;
- (Class)shapeClassForSelectedTool;
@end
