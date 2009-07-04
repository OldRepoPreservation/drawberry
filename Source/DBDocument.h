//
//  DBDocument.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBDrawingView;
@class DBLayerController;
@class DBUndoManager;
@class DBSVGParser;

@interface DBDocument : NSDocument {
	IBOutlet DBDrawingView *_drawingView;
	IBOutlet DBLayerController *_layerController;
	
	IBOutlet NSView *_exportAccessoryView;
	IBOutlet NSPopUpButton *_exportFormatPopUp;
//	IBOutlet NSButton *_exportOptions;
	IBOutlet NSSlider *_jpgQualitySlider;
	NSSavePanel *_currentExportPanel;
	
	NSArray *_tmpLayers;
	NSDictionary *_tmpDict;
	NSImage* _tmpImage;
	
	DBUndoManager *_undoMngr;
	
	DBSVGParser *_svgParser;
	
	// SVG sheet
	IBOutlet NSPanel *_svgSheet;
	IBOutlet NSProgressIndicator *_svgProgressIndicator;
}
+ (id)sharedUnitArray;

+ (NSString *)formatForTag:(int)tag;
+ (NSString *)unitForIndex:(int)index;
+ (NSString *)defaultUnit;

- (DBDrawingView *)drawingView;
- (DBLayerController *)layerController;

- (IBAction)export:(id)sender;
- (void)exportChooseFileDidEnd:(NSSavePanel*)sheet returnCode:(int)code contextInfo:(void*)contextInfo;
- (IBAction)exportAccessoryViewPopupFormatDidChange:(id)sender;

- (DBUndoManager *)specialUndoManager;

- (IBAction)cancelSVGLoad:(id)sender;
@end
