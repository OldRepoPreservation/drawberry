//
//  DBShapeLibraryController.h
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBMatrix.h"
@class DBShapeLibLayerController;
@class DBShape;
@class DDDAnimatedTabView, DBShapeCollection;

@interface DBShapeLibraryController : NSWindowController {
	IBOutlet DBMatrix *_matrix;
	IBOutlet DBShapeLibLayerController *_layerController;
	IBOutlet DDDAnimatedTabView *_tabView;
	IBOutlet NSImageView *_lockImage;
	IBOutlet NSTableView *_collectionView;
		
	NSMutableArray *_shapeCollections;
}                              
+ (id)sharedShapeLibraryController;
- (id)init;
- (IBAction)reload:(id)sender;

- (DBShape *)editedShape;
- (void)removeEditedShape;
- (void)newShape:(DBShape *)shape;

- (void)writeShapeLibrary;
- (void)readShapeLibrary;

- (IBAction)addShape:(id)sender;
- (IBAction)editDone:(id)sender;

- (DBShapeCollection *)selectedCollection;
- (IBAction)addCollection:(id)sender;
- (IBAction)removeCollection:(id)sender;
- (IBAction)duplicateCollection:(id)sender;
- (void)sortCollections;

- (void)updateCollectionList;
@end
