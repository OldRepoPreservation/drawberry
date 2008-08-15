//
//  DBLayerWindowController.h
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBLayer;

@interface DBLayerWindowController : NSWindowController {
	IBOutlet NSArrayController *_layersArrayController;
	IBOutlet NSTableView *_layersTableView;
	IBOutlet NSDrawer *_layerPanelDrawer;
}
+ (id)sharedLayerWindowController;

- (DBLayer *)currentLayer;

- (IBAction)raiseSelectedLayer:(id)sender;
- (IBAction)lowerSelectedLayer:(id)sender;
- (IBAction)raiseAtTopSelectedLayer:(id)sender;
- (IBAction)lowerAtBottomSelectedLayer:(id)sender;
- (IBAction)addCILayer:(id)sender;
@end
