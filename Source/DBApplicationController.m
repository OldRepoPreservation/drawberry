//
//  DBApplicationController.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
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

#import "DBDonateWindowController.h"

NSString *DBCurrentDocumentDidChange = @"Current document did change";

@implementation DBApplicationController 
+ (void)initialize
{
	[self exposeBinding:@"currentDrawingView"];
	[self exposeBinding:@"currentLayerController"];


	NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];
   	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:DBToolSelectorMode];
   	[defaultValues setObject:[NSNumber numberWithInt:2] forKey:DBUnitName];
	
   	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:DBNewDocumentAtStartup];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:DBDefaultTemplateTag]; // A4 template
	
	
	
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


- (void)awakeFromNib
{      
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
}   

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:DBNewDocumentAtStartup];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification { 
	

	if([[NSUserDefaults standardUserDefaults] boolForKey:DBLayerWindowOpened]){
		[[DBLayerWindowController sharedLayerWindowController] showWindow:self];
	}
	
	[[DBInspectorController sharedInspectorController] loadWindow];

	if([[NSUserDefaults standardUserDefaults] boolForKey:DBViewInspectorOpened]){
		[[[DBInspectorController sharedInspectorController] viewInspector] makeKeyAndOrderFront:self];
	}else{
		[[[DBInspectorController sharedInspectorController] viewInspector] orderOut:self];
	}

	if([[NSUserDefaults standardUserDefaults] boolForKey:DBObjectInspectorOpened]){
		[[[DBInspectorController sharedInspectorController] objectInspector] makeKeyAndOrderFront:self];
	}else {
		[[[DBInspectorController sharedInspectorController] objectInspector] orderOut:self];

	}

	
	if([[NSUserDefaults standardUserDefaults] boolForKey:DBMagGlassPanelOpened]){
		[[DBMagnifyingController sharedMagnifyingController] showWindow:self];
	}
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:DBUndoWindowOpened]){
		[[DBUndoUIController sharedUndoUIController] showWindow:self];
	}else{
		[[DBUndoUIController sharedUndoUIController] close];
	}
	if([[NSUserDefaults standardUserDefaults] boolForKey:DBColorSwatchOpened]){
		[[DBColorSwatchController sharedColorSwatchController] showWindow:self];
	}else {
		[[DBColorSwatchController sharedColorSwatchController] close];
	}

	
	if([[NSUserDefaults standardUserDefaults] boolForKey:DBShapeLibraryOpened]){
		[[DBShapeLibraryController sharedShapeLibraryController] showWindow:self];
	}else {
		[[DBShapeLibraryController sharedShapeLibraryController] close];
	}

	
	[[DBToolsController sharedToolsController] showWindow:self];

	
	[_donationController showDonateWindowIfNecessary];
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

- (NSWindow *)undoWindow
{
	return [[DBUndoUIController sharedUndoUIController] window];
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
