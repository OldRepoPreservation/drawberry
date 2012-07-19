//
//  DBApplicationController.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBDrawingView, DBLayerController, DBGroupController;
@class DBDonateWindowController;

extern NSString *DBCurrentDocumentDidChange;

@interface DBApplicationController : NSObject {
	IBOutlet DBDonateWindowController *_donationController;
}
- (DBDrawingView *)currentDrawingView; 
- (DBLayerController *)currentLayerController;
- (DBGroupController *)currentGroupController;
- (IBAction)showInspector:(id)sender;
- (IBAction)showShapeInspector:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)showUndoPanel:(id)sender;
- (IBAction)showColorSwatches:(id)sender;
- (IBAction)showShapeLibrary:(id)sender;
- (IBAction)showGroupsPanel:(id)sender;
- (IBAction)showLayersPanel:(id)sender;

- (NSWindow *)layerWindow;
- (NSWindow *)viewInspector;
- (NSWindow *)objectInspector;
- (NSWindow *)magnifyWindow;
- (NSWindow *)undoWindow;
- (NSWindow *)colorSwatchesWindow;
- (NSWindow *)shapeLibraryWindow;
- (NSWindow *)groupsWindow;

- (void)postCurrentDocChangedNotification;
@end
