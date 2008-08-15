//
//  DBToolsController.m
//  DrawBerry
//
//  Created by Raphael Bost on 15/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBToolsController.h"
#import "DBToolMatrix.h"


#import "GCollapseWindow.h"
#import "DBApplicationController.h"

@class DBShape, DBRectangle, DBOval, DBLine, DBPolyline, DBBezierCurve, DBText;

NSString *DBSelectedToolDidChangeNotification = @"DBSelectedToolDidChangeNotification";
NSString *DBToolDidCreateShapeNotification = @"DBToolDidCreateShapeNotification";
    
static DBToolsController *_sharedToolsController = nil; 

enum {
	DBArrowTool =  0,
	DBRectTool = 1,
	DBOvalTool = 2,
	DBPolylineTool = 3,
	DBLineTool = 4,
	DBBezierCurveTool = 5,
	DBTextTool = 6
};   

@implementation DBToolsController
+ (id)sharedToolsController
{
	if(!_sharedToolsController)
	{
		_sharedToolsController = [[DBToolsController allocWithZone:[self zone]] init];
	}
	
	return _sharedToolsController;
}

- (id)init {
    self = [self initWithWindowNibName:@"DBTools"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBTools"];
    }
    return self;
}

- (void)awakeFromNib
{
	[(GCollapseWindow *)[self window] setWidthWhenClosed:[[self window] frame].size.width];

   	[[_toolButtons cellWithTag:0] setHighlighted:YES];
	[[_toolButtons cellWithTag:0] setLocked:YES];  	

	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:[[NSApp delegate] viewInspector]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:[[NSApp delegate] objectInspector]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:[[NSApp delegate] layerWindow]];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:[[NSApp delegate] magnifyWindow]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillOpen:) 
												 name:NSWindowDidBecomeKeyNotification 
											   object:[[NSApp delegate] viewInspector]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillOpen:) 
												 name:NSWindowDidBecomeKeyNotification 
											   object:[[NSApp delegate] objectInspector]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillOpen:) 
												 name:NSWindowDidBecomeKeyNotification 
											   object:[[NSApp delegate] layerWindow]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillOpen:) 
												 name:NSWindowDidBecomeKeyNotification 
											   object:[[NSApp delegate] magnifyWindow]];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(toolDidCreateShape:) 
												 name:DBToolDidCreateShapeNotification 
											   object:nil];
	

	[[_inspectorSelector cellWithTag:0] setState:NSOnState];
	[[_inspectorSelector cellWithTag:1] setState:NSOnState];
	[[_inspectorSelector cellWithTag:2] setState:NSOnState];
	[[_inspectorSelector cellWithTag:3] setState:NSOffState];

}

- (IBAction)selectToolAction:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBSelectedToolDidChangeNotification object:self];
}

- (int)selectedTool
{
	return [[_toolButtons selectedCell] tag];
}

- (Class)shapeClassForSelectedTool
{
	Class class = nil;
	
	switch([self selectedTool]){
		case DBRectTool :			class = [DBRectangle class]; break;
		case DBOvalTool :   		class = [DBOval class];	break;
		case DBPolylineTool :   	class = [DBPolyline class]; break;
		case DBLineTool :   		class = [DBLine class]; break;
		case DBBezierCurveTool :   	class = [DBBezierCurve class]; break;
		case DBTextTool :   		class = [DBText class]; break;
	}   
	return class;
}


- (void)inspectorWindowWillClose:(NSNotification *)note
{
	NSWindow *window;
	window = [note object];
	int tag;
	
	if(window == [[NSApp delegate] viewInspector]){
		tag = 0;
	}else if(window == [[NSApp delegate] objectInspector]){
		tag = 1;
	}else if(window == [[NSApp delegate] layerWindow]){
		tag = 2;
	}else if(window == [[NSApp delegate] magnifyWindow]){
		tag = 3;
	}           
	
	[[_inspectorSelector cellWithTag:tag] setState:NSOffState];
}

- (void)inspectorWindowWillOpen:(NSNotification *)note
{
	NSWindow *window;
	window = [note object];
	int tag;
	
	if(window == [[NSApp delegate] viewInspector]){
		tag = 0;
	}else if(window == [[NSApp delegate] objectInspector]){
		tag = 1;
	}else if(window == [[NSApp delegate] layerWindow]){
	  	tag = 2;
    }else if(window == [[NSApp delegate] magnifyWindow]){ 
		tag = 3;
	}           
	           
	
	[[_inspectorSelector cellWithTag:tag] setState:NSOnState];
}

- (void)toolDidCreateShape:(NSNotification *)note
{
	// [_toolButtons selectCellWithTag:0];
	// [[_toolButtons cellWithTag:0] setHighlighted:YES];
	// [[_toolButtons cellWithTag:0] setLocked:YES];  	
	[(DBToolMatrix *)_toolButtons toolDidEnd:self];
}

- (IBAction)inspectorSelectorAction:(id)sender
{
   	if([[_inspectorSelector cellWithTag:0] state] != [[[NSApp delegate] viewInspector] isVisible]){
		if([[_inspectorSelector cellWithTag:0] state]){
			[[[NSApp delegate] viewInspector] makeKeyAndOrderFront:self];
		}else{
			[[[NSApp delegate] viewInspector] orderOut:self];
		}
	}

	if([[_inspectorSelector cellWithTag:1] state] != [[[NSApp delegate] objectInspector] isVisible]){
		if([[_inspectorSelector cellWithTag:1] state]){
			[[[NSApp delegate] objectInspector] makeKeyAndOrderFront:self];
		}else{
			[[[NSApp delegate] objectInspector] orderOut:self];
		}
	}

	if([[_inspectorSelector cellWithTag:2] state] != [[[NSApp delegate] layerWindow] isVisible]){
		if([[_inspectorSelector cellWithTag:2] state]){
			[[[NSApp delegate] layerWindow] makeKeyAndOrderFront:self];
		}else{
			[[[NSApp delegate] layerWindow] orderOut:self];
		}
	}
	if([[_inspectorSelector cellWithTag:3] state] != [[[NSApp delegate] magnifyWindow] isVisible]){
		if([[_inspectorSelector cellWithTag:3] state]){
			[[[NSApp delegate] magnifyWindow] makeKeyAndOrderFront:self];
		}else{
			[[[NSApp delegate] magnifyWindow] orderOut:self];
		}
	}
}
@end
