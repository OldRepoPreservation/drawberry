//
//  DBApplicationController.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "DBPrefKeys.h"

#import "DBApplicationController.h"

#import "DBInspectorController.h"
#import "DBLayerWindowController.h"   
#import "DBToolsController.h"
#import "DBPrefController.h" 
#import "DBUndoUIController.h"


#import "DBDocument.h"
#import "DBDrawingView.h"

#import "DBLayerController.h"

#import "DBMagnifyingController.h"
#import "DBMagnifyingView.h"

#import "DBColorSwatchController.h"
#import "DBShapeLibraryController.h"


NSString *DBCurrentDocumentDidChange = @"Current document did change";

@implementation DBApplicationController 
+ (void)initialize
{
	[self exposeBinding:@"currentDrawingView"];
	[self exposeBinding:@"currentLayerController"];


	NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];
   	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:DBToolSelectorMode];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

	[defaultValues release];

}     


- (void)awakeFromNib
{      
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
}   

- (void)applicationDidFinishLaunching:(NSNotification *)notification { 
	[[DBLayerWindowController sharedLayerWindowController] showWindow:self];
	[[DBInspectorController sharedInspectorController] showWindow:self];
	[[DBToolsController sharedToolsController] showWindow:self];
	[[DBUndoUIController sharedUndoUIController] showWindow:self];
	
//	[[DBColorSwatchController sharedColorSwatchController] showWindow:self];
//	[[DBShapeLibraryController sharedShapeLibraryController] showWindow:self];
//	[[DBMagnifyingController sharedMagnifyingController] showWindow:self];
}  

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
/*   	[self willChangeValueForKey:@"currentDrawingView"];
	[self didChangeValueForKey:@"currentDrawingView"];                                                    
 */ 
	[self performSelector:@selector(willChangeValueForKey:) withObject:@"currentDrawingView" afterDelay:FLT_MIN];
	[self performSelector:@selector(didChangeValueForKey:) withObject:@"currentDrawingView" afterDelay:FLT_MIN];
	[self performSelector:@selector(willChangeValueForKey:) withObject:@"currentLayerController" afterDelay:FLT_MIN];
	[self performSelector:@selector(didChangeValueForKey:) withObject:@"currentLayerController" afterDelay:FLT_MIN];
	
	[self performSelector:@selector(postCurrentDocChangedNotification) withObject:nil afterDelay:FLT_MIN];
	[self performSelector:@selector(setMagnyfiedView) withObject:nil afterDelay:FLT_MIN];
}
              
- (void)setMagnyfiedView
{
	[[DBMagnifyingController sharedMagnifyingView] setSource:[self currentDrawingView]];
}
- (void)windowWillClose:(NSNotification *)aNotification
{
	//we have to wait a bit
 	
	if(![[aNotification object] isKindOfClass:[NSPanel class]]){
	   	[self performSelector:@selector(willChangeValueForKey:) withObject:@"currentDrawingView" afterDelay:FLT_MIN];
		[self performSelector:@selector(didChangeValueForKey:) withObject:@"currentDrawingView" afterDelay:FLT_MIN];
		[self performSelector:@selector(willChangeValueForKey:) withObject:@"currentLayerController" afterDelay:FLT_MIN];
		[self performSelector:@selector(didChangeValueForKey:) withObject:@"currentLayerController" afterDelay:FLT_MIN];
	
		[self performSelector:@selector(postCurrentDocChangedNotification) withObject:nil afterDelay:FLT_MIN];
		
		[self performSelector:@selector(setMagnyfiedView) withObject:nil afterDelay:FLT_MIN];
	}
}
 
- (void)postCurrentDocChangedNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBCurrentDocumentDidChange object:[[NSDocumentController sharedDocumentController] currentDocument]];
}
- (void)applicationDidResignActive:(NSNotification *)aNotification
{
}
- (void)windowDidBecomeMain:(NSNotification *)aNotification
{                
//	NSLog(@"main : %@",[[NSDocumentController sharedDocumentController] documentForWindow:[aNotification object]]);
	[self willChangeValueForKey:@"currentDrawingView"];
	[self didChangeValueForKey:@"currentDrawingView"];
	[self willChangeValueForKey:@"currentLayerController"];
	[self didChangeValueForKey:@"currentLayerController"];

	[[NSNotificationCenter defaultCenter] postNotificationName:DBCurrentDocumentDidChange object:[[NSDocumentController sharedDocumentController] currentDocument]];
	[[DBMagnifyingController sharedMagnifyingView] setSource:[self currentDrawingView]];
}

- (DBDrawingView *)currentDrawingView
{         
	if(![[[NSDocumentController sharedDocumentController] currentDocument] isKindOfClass:[DBDocument class]])
	{
		return nil;
	}
	
	id current = [(DBDocument *)[[NSDocumentController sharedDocumentController] currentDocument] drawingView];
		
	if(!current)
	{
		current = [(DBDocument *)[[NSDocumentController sharedDocumentController] documentForWindow:[NSApp mainWindow]] drawingView];		
	}
	
	return current;
}

- (DBLayerController *)currentLayerController
{              
	if(![[[NSDocumentController sharedDocumentController] currentDocument] isKindOfClass:[DBDocument class]])
	{
		return nil;
	}

	id current = [(DBDocument *)[[NSDocumentController sharedDocumentController] currentDocument] layerController];
		
	if(!current)
	{
		current = [(DBDocument *)[[NSDocumentController sharedDocumentController] documentForWindow:[NSApp mainWindow]] layerController];		
	}
	
	return current;
} 

- (IBAction)showInspector:(id)sender
{
	[[DBInspectorController sharedInspectorController] showWindow:sender];
}

- (IBAction)showShapeInspector:(id)sender
{
	[[[DBInspectorController sharedInspectorController] objectInspector] makeKeyAndOrderFront:sender];
}
- (IBAction)showPrefs:(id)sender
{
	[[DBPrefController sharedPrefController] showWindow:sender];
}

- (IBAction)showUndoPanel:(id)sender
{    
	[[DBUndoUIController sharedUndoUIController] showWindow:self];
}

- (IBAction)showColorSwatches:(id)sender
{
	[[DBColorSwatchController sharedColorSwatchController] showWindow:self];
}

- (IBAction)showShapeLibrary:(id)sender
{
	[[DBShapeLibraryController sharedShapeLibraryController] showWindow:self];
}

- (NSWindow *)layerWindow
{
	return [[DBLayerWindowController sharedLayerWindowController] window];
}   

- (NSWindow *)viewInspector
{
	return [[DBInspectorController sharedInspectorController] viewInspector];	
}
- (NSWindow *)objectInspector
{
	return [[DBInspectorController sharedInspectorController] objectInspector];	
}

- (NSWindow *)magnifyWindow
{
	return [[DBMagnifyingController sharedMagnifyingController] window];
}

- (NSWindow *)colorSwatchesWindow
{
	return [[DBColorSwatchController sharedColorSwatchController] window];
}

- (NSWindow *)shapeLibraryWindow
{
	return [[DBShapeLibraryController sharedShapeLibraryController] window];
}
@end
