//
//  DBShapeLibLayerController.h
//  DrawBerry
//
//  Created by Raphael Bost on 18/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBLayerController.h"   

@class DBShapeLibraryController;
@class DBShape;

@interface DBShapeLibLayerController : DBLayerController {
	IBOutlet DBShapeLibraryController *_libController;
	IBOutlet DBDrawingView *_shapeEditor;
	
	DBShape *_editedShape;
}                                           
- (void)editShape:(DBShape *)shape;
- (void)removeEditedShape;
@end
