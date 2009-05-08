//
//  DBToolsController.m
//  DrawBerry
//
//  Created by Raphael Bost on 15/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBToolsController.h"
#import "DBToolMatrix.h"


#import "GCollapsePanel.h"
#import "DBApplicationController.h"
#import "DBMagnifyingController.h"

#import "DBPrefKeys.h"

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

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];

   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBViewInspectorOpened];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBObjectInspectorOpened];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBLayerWindowOpened];
   	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:DBMagGlassPanelOpened];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBUndoWindowOpened];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:DBColorSwatchOpened];
   	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:DBShapeLibraryOpened];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
	[defaultValues release];	
}

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
	[(GCollapsePanel *)[self window] setWidthWhenClosed:[[self window] frame].size.width];

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
	

	[[_inspectorSelector cellWithTag:0] setState:[[[NSApp delegate] viewInspector] isVisible]];
	[[_inspectorSelector cellWithTag:1] setState:[[[NSApp delegate] objectInspector] isVisible]];
	[[_inspectorSelector cellWithTag:2] setState:[[[NSApp delegate] layerWindow] isVisible]];
	[[_inspectorSelector cellWithTag:3] setState:[[DBMagnifyingController sharedMagnifyingController] isWindowLoaded]];

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
	NSString *key;
	key = nil;
	window = [note object];
	int tag;
	
	if(window == [[NSApp delegate] viewInspector]){
		tag = 0;
		key = DBViewInspectorOpened;
	}else if(window == [[NSApp delegate] objectInspector]){
		tag = 1;
		key = DBObjectInspectorOpened;
	}else if(window == [[NSApp delegate] layerWindow]){
		tag = 2;
		key = DBLayerWindowOpened;
	}else if(window == [[NSApp delegate] magnifyWindow]){
		tag = 3;
		key = DBMagGlassPanelOpened;
	}else if(window == [[NSApp delegate] undoWindow]){
		tag = 4;
		key = DBUndoWindowOpened;
	}else if(window == [[NSApp delegate] colorSwatchesWindow]){
		tag = 5;
		key = DBColorSwatchOpened;
	}else if(window == [[NSApp delegate] shapeLibraryWindow]){
		tag = 6;
		key = DBShapeLibraryOpened;
	}           
	
	
	if(key){
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
		
		if(tag <= 3)
			[[_inspectorSelector cellWithTag:tag] setState:NSOffState];		
	}
}

- (void)inspectorWindowWillOpen:(NSNotification *)note
{
	NSWindow *window;
	NSString *key;
	key = nil;
	window = [note object];
	int tag;
	
	if(window == [[NSApp delegate] viewInspector]){
		tag = 0;
		key = @"viewInspector Opened";
	}else if(window == [[NSApp delegate] objectInspector]){
		tag = 1;
		key = @"objectInspector Opened";
	}else if(window == [[NSApp delegate] layerWindow]){
		tag = 2;
		key = @"layerWindow Opened";
	}else if(window == [[NSApp delegate] magnifyWindow]){
		tag = 3;
		key = @"magGlassPanel Opened";
	}           
	
	if(key){
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
		
		[[_inspectorSelector cellWithTag:tag] setState:NSOnState];		
	}
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
	BOOL flag;
   	if([[_inspectorSelector cellWithTag:0] state] != [[[NSApp delegate] viewInspector] isVisible]){
		if([[_inspectorSelector cellWithTag:0] state]){
			[[[NSApp delegate] viewInspector] makeKeyAndOrderFront:self];
			flag = YES;
		}else{
			[[[NSApp delegate] viewInspector] orderOut:self];
			flag = NO;
		}
		[[NSUserDefaults standardUserDefaults] setBool:flag forKey:@"viewInspector Opened"];
	}

	if([[_inspectorSelector cellWithTag:1] state] != [[[NSApp delegate] objectInspector] isVisible]){
		if([[_inspectorSelector cellWithTag:1] state]){
			[[[NSApp delegate] objectInspector] makeKeyAndOrderFront:self];
			flag = YES;
		}else{
			[[[NSApp delegate] objectInspector] orderOut:self];
			flag = NO;
		}
		[[NSUserDefaults standardUserDefaults] setBool:flag forKey:@"objectInspector Opened"];
	}

	if([[_inspectorSelector cellWithTag:2] state] != [[[NSApp delegate] layerWindow] isVisible]){
		if([[_inspectorSelector cellWithTag:2] state]){
			[[[NSApp delegate] layerWindow] makeKeyAndOrderFront:self];
			flag = YES;
		}else{
			[[[NSApp delegate] layerWindow] orderOut:self];
			flag = NO;
		}
		[[NSUserDefaults standardUserDefaults] setBool:flag forKey:@"layerWindow Opened"];
	}

	if([[_inspectorSelector cellWithTag:3] state] != [[[NSApp delegate] magnifyWindow] isVisible]){
		if([[_inspectorSelector cellWithTag:3] state]){
			[[[NSApp delegate] magnifyWindow] makeKeyAndOrderFront:self];
			flag = YES;
		}else{
			[[[NSApp delegate] magnifyWindow] orderOut:self];
			flag = NO;
		}
		[[NSUserDefaults standardUserDefaults] setBool:flag forKey:@"magGlassPanel Opened"];
	}
}
@end
