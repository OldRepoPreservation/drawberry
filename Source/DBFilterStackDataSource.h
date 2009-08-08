//
//  DBFilterStackDataSource.h
//  DrawBerry
//
//  Created by Raphael Bost on 25/06/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBLayerController, DBFilterStack;
@interface DBFilterStackDataSource : NSObject {
	DBFilterStack *_effectStack;
	DBLayerController *_layerController;
	IBOutlet NSArrayController *_layerArrayController;
	IBOutlet NSTableView *_filtersTableView;
}
- (IBAction)add:(id)sender;
@end
