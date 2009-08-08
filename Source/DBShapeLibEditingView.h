//
//  DBShapeLibEditingView.h
//  DrawBerry
//
//  Created by Raphael Bost on 19/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBDrawingView.h"

@class DBShapeLibLayerController;

@interface DBShapeLibEditingView : DBDrawingView {
	IBOutlet DBShapeLibLayerController *_layerController;
}

@end
