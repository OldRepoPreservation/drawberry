//
//  DBInspectorController.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
         

@class GInspectWindow;

@interface DBInspectorController : NSWindowController {
	IBOutlet GInspectWindow *_viewInspector;
	IBOutlet GInspectWindow *_objectInspector;
	
	IBOutlet id _link;

    // All the inspection views

	// view
	IBOutlet NSView *_gridView;
	IBOutlet NSView *_rulerView;
	IBOutlet NSView *_canevasView;
	
	// shape
	IBOutlet NSView *_geometryView;
	IBOutlet NSView *_strokeView;
	IBOutlet NSView *_fillView;
	IBOutlet NSView *_arrowView;
	IBOutlet NSView *_shadowView;
	IBOutlet NSView *_textView;

	IBOutlet NSImageView *_fillImageView;
	IBOutlet NSImageView *_strokeImageView;
	
	IBOutlet NSObjectController *_fillController;
	IBOutlet NSObjectController *_strokeController;
	IBOutlet NSObjectController *_shadowController;
	IBOutlet NSArrayController *_fillsController;
	IBOutlet NSControl *_fillGradientWell;
	IBOutlet NSControl *_fillColorWell;
	IBOutlet NSControl *_shadowControl;
	IBOutlet NSSlider  *_strokeThickness;
	
}
+ (id)sharedInspectorController;
- (id)applicationController; 

- (IBAction)action:(id)sender;

- (IBAction)chooseStrokeImage:(id)sender;
- (IBAction)chooseFillImage:(id)sender;
- (IBAction)shadowAction:(id)sender;
- (IBAction)flipText:(id)sender;
- (IBAction)clearText:(id)sender;

- (IBAction)takeGradientFrom:(id)sender;

- (NSWindow *)viewInspector;
- (NSWindow *)objectInspector;
@end
