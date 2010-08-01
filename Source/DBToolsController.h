//
//  DBToolsController.h
//  DrawBerry
//
//  Created by Raphael Bost on 15/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *DBSelectedToolDidChangeNotification;
extern NSString *DBToolDidCreateShapeNotification;

@class DBShape, DBDrawingView;

@interface DBToolsController : NSWindowController {
	IBOutlet	NSMatrix *_toolButtons;
	IBOutlet    NSMatrix *_inspectorSelector;
}
+ (id)sharedToolsController;
- (IBAction)selectToolAction:(id)sender;
- (IBAction)inspectorSelectorAction:(id)sender; 

- (int)selectedTool;
- (Class)shapeClassForSelectedTool;

- (void)registerForOpenNotifications;
- (void)registerForCloseNotifications;

#pragma mark Shape Creation
- (DBShape *)intializeNewShapeWithCurrentTool;
- (BOOL)createShape:(DBShape *)shape withEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view;
@end
