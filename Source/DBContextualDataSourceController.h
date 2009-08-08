//
//  DBContextualDataSourceController.h
//  DrawBerry
//
//  Created by Raphael Bost on 24/02/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBContextualBar.h"

@class DBDrawingView;

@interface DBContextualDataSourceController : NSObject <DBContextualBarDataSource> {
	IBOutlet DBContextualBar *_contextualBar;
	IBOutlet DBDrawingView *_mainView;
	
	IBOutlet NSView *_voidView;
	IBOutlet NSView *_selectView;
	IBOutlet NSView *_bezierView;
	IBOutlet NSView *_rectangleView;
	IBOutlet NSView *_ovalView;
	IBOutlet NSView *_textView;
	
	
	IBOutlet NSButton *_convertButton;
	IBOutlet NSBox *_convertBox;
	IBOutlet NSButton *_replaceButton;
	IBOutlet NSBox *_textEditBox;
	IBOutlet NSSegmentedControl *_alignControl;
	IBOutlet NSSegmentedControl *_vertAlignControl;
	
   	IBOutlet NSBox *_multipleSelectionBox;
 	IBOutlet NSPopUpButton *_booleanOp;
	IBOutlet NSPopUpButton *_alignment;
	
	int _selectionType; // 0 : none, 1 : selection, 2 : edition
}

- (void)updateSelection;
- (void)beginEditing;
- (void)endEditing;

- (IBAction)duplicate:(id)sender;
- (IBAction)delete:(id)sender; 

- (IBAction)addControlPoint:(id)sender;
- (IBAction)removeControlPoint:(id)sender;
- (IBAction)replace:(id)sender;
- (IBAction)convert:(id)sender; 

- (IBAction)align:(id)sender;
- (IBAction)vertAlign:(id)sender;


- (IBAction)stopEditing:(id)sender;
                             
- (IBAction)raise:(id)sender;
- (IBAction)lower:(id)sender;


- (IBAction)union:(id)sender;  
- (IBAction)diff:(id)sender;
- (IBAction)intersection:(id)sender;
- (IBAction)xor:(id)sender;   

- (IBAction)left:(id)sender;  
- (IBAction)center:(id)sender;
- (IBAction)right:(id)sender;
- (IBAction)top:(id)sender;  
- (IBAction)middle:(id)sender;
- (IBAction)bottom:(id)sender;

@end
