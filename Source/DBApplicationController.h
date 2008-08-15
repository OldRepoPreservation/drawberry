//
//  DBApplicationController.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBDrawingView, DBLayerController;

extern NSString *DBCurrentDocumentDidChange;

@interface DBApplicationController : NSObject {

}
- (DBDrawingView *)currentDrawingView; 
- (DBLayerController *)currentLayerController;
- (IBAction)showInspector:(id)sender;
- (IBAction)showShapeInspector:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)showUndoPanel:(id)sender;
- (IBAction)showColorSwatches:(id)sender;
- (IBAction)showShapeLibrary:(id)sender;

- (NSWindow *)layerWindow;
- (NSWindow *)viewInspector;
- (NSWindow *)objectInspector;
- (NSWindow *)magnifyWindow;
- (NSWindow *)colorSwatchesWindow;
- (NSWindow *)shapeLibraryWindow;

- (void)postCurrentDocChangedNotification;
@end
