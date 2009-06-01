//
//  DBDocument.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBDocument.h"
#import "DBDocument+SVG.h"

#import "DBDrawingView.h"
#import "DBLayerController.h"
#import "DBDrawingView+Exporting.h"
#import "DBUndoManager.h"

#import "DBSVGParser.h"

#import "DBPrefKeys.h"

static NSArray *_sharedUnitArray = nil;

@implementation DBDocument

+ (id)sharedUnitArray
{
    if (!_sharedUnitArray) {
        _sharedUnitArray = [[NSArray allocWithZone:[self zone]] initWithObjects:@"Inches",@"Centimeters",@"Points",@"Picas",nil];
    }
    return _sharedUnitArray;
}

+ (NSString *)formatForTag:(int)tag
{
	NSString *format;
	              
	switch(tag){
		case 0 :	format = @"PDF"; break;
		case 1 :	format = @"EPS"; break;
		case 2 :	format = @"TIFF"; break;
		case 3 :	format = @"PNG"; break;
		case 4 :	format = @"JPEG"; break;
		case 5 :	format = @"PSD"; break;
		case 6 :	format = @"AI"; break;
		case 7 :	format = @"SVG"; break;
		default : format = nil; break;
	}
	return format;
}   

+ (NSString *)unitForIndex:(int)index
{
	return [[DBDocument sharedUnitArray] objectAtIndex:index];
}

+ (NSString *)defaultUnit
{
	return [self unitForIndex:[[NSUserDefaults standardUserDefaults] integerForKey:DBUnitName]];
}

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
       
		_undoMngr = [[DBUndoManager alloc] init];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_undoMngr release];
	
	
	[super dealloc];
}

- (NSString *)windowNibName 
{
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"DBDocument";
}
                     
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    // Implement to provide a persistent data representation of your document OR remove this and implement the file-wrapper or file path based save methods.
	       
	//NSLog(@"typeName %@", typeName);                                     
	
	if(![typeName isEqualToString:@"DrawBerry Document"]){
		NSString *path = [absoluteURL path];
		path = [path stringByDeletingPathExtension];
		path = [path stringByAppendingPathExtension:@"dbdoc"];
	}
	
	NSData *data;
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	
	data = [NSKeyedArchiver archivedDataWithRootObject:[_layerController layers]];
	
	[dict setObject:data forKey:@"Layers and shapes"];
	[dict setObject:[NSKeyedArchiver archivedDataWithRootObject:[_drawingView backgroundColor]] forKey:@"Canvas Background Color"];
	[dict setObject:[NSKeyedArchiver archivedDataWithRootObject:[_drawingView gridColor]] forKey:@"Grid Color"];
	[dict setObject:[NSKeyedArchiver archivedDataWithRootObject:[_drawingView canevasColor]] forKey:@"Canvas Color"];
	[dict setObject:[NSNumber numberWithFloat:[_drawingView canevasSize].width] forKey:@"Canvas Width"];
	[dict setObject:[NSNumber numberWithFloat:[_drawingView canevasSize].height] forKey:@"Canvas Height"];
	[dict setObject:[NSNumber numberWithBool:[_drawingView showGrid]] forKey:@"Show Grid"];
	[dict setObject:[NSNumber numberWithFloat:[_drawingView gridSpacing]] forKey:@"Grid Spacing"];
	[dict setObject:[NSNumber numberWithInt:[_drawingView gridTickCount]] forKey:@"Grid Tick Count"];
	[dict setObject:[NSNumber numberWithBool:[_drawingView showRulers]] forKey:@"Show Rulers"];
	[dict setObject:[NSNumber numberWithBool:[_drawingView snapToGrid]] forKey:@"Snap to grid"];
	
	[self updateChangeCount:NSChangeCleared];
	
	
	return [dict writeToURL:absoluteURL atomically:NO];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    // Implement to load a persistent data representation of your document OR remove this and implement the file-wrapper or file path based load methods.
	
	if([typeName isEqualToString:@"DrawBerry Document"]){
			_tmpDict = [[NSDictionary alloc] initWithContentsOfURL:absoluteURL];
			_tmpImage = nil;

			if(!_layerController){
		//		_tmpLayers = [newLayers retain];

			}else{      
				NSArray *newLayers = [NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Layers and shapes"]];
				[_layerController setLayers:newLayers];

			    [_drawingView setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Canvas Background Color"]]];
			    [_drawingView setGridColor:[NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Grid Color"]]];
			    [_drawingView setCanevasColor:[NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Canvas Color"]]];
				[_drawingView setCanevasWidth:[[_tmpDict objectForKey:@"Canvas Width"] floatValue]];
				[_drawingView setCanevasHeight:[[_tmpDict objectForKey:@"Canvas Height"] floatValue]];
				[_drawingView setShowGrid:[[_tmpDict objectForKey:@"Show Grid"] boolValue]];
				[_drawingView setGridSpacing:[[_tmpDict objectForKey:@"Grid Spacing"] floatValue]];
				[_drawingView setGridTickCount:[[_tmpDict objectForKey:@"Grid Tick Count"] intValue]];
				[_drawingView setSnapToGrid:[[_tmpDict objectForKey:@"Snap to grid"] boolValue]];
				[_drawingView setShowRulers:[[_tmpDict objectForKey:@"Show Rulers"] boolValue]];

				[_layerController updateLayersRender];
				
				[_tmpDict release];
				_tmpDict = nil;
			}   		
	}else if([typeName isEqualToString:@"SVG Document"]){
		NSArray *svgLayers;
		
		svgLayers = [DBSVGParser parseSVGURL:absoluteURL];
		
		if(!_layerController){
			_tmpLayers = [svgLayers retain];
		}else{
			[_layerController setLayers:svgLayers];
		}
		
	}else{
		// we have an image
		_tmpImage = [[NSImage alloc] initWithContentsOfURL:absoluteURL];
		[_tmpImage setFlipped:YES];
		_tmpDict = nil;
		
		if(!_layerController){

		}else{      
			[[[_layerController layers] objectAtIndex:0] setBackgroundImage:_tmpImage];
 		    [_drawingView setCanevasWidth:[_tmpImage size].width];
			[_drawingView setCanevasHeight:[_tmpImage size].height];
   	
			[_tmpImage release];
			_tmpImage = nil;
		}
	}
	
	
//	NSLog(@"newLayers : %@", newLayers);
	[self updateChangeCount:NSChangeCleared];	
    
	[_drawingView setNeedsDisplay:YES];
		
	return YES;
}

- (void)awakeFromNib
{
	if(_tmpDict){
		NSArray *newLayers = [NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Layers and shapes"]];
 		[_layerController setLayers:newLayers];
   		
		[_drawingView setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Canvas Background Color"]]];
		[_drawingView setGridColor:[NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Grid Color"]]];
		[_drawingView setCanevasColor:[NSKeyedUnarchiver unarchiveObjectWithData:[_tmpDict objectForKey:@"Canvas Color"]]];
		[_drawingView setCanevasWidth:[[_tmpDict objectForKey:@"Canvas Width"] floatValue]];
		[_drawingView setCanevasHeight:[[_tmpDict objectForKey:@"Canvas Height"] floatValue]];
		[_drawingView setShowGrid:[[_tmpDict objectForKey:@"Show Grid"] boolValue]];
		[_drawingView setGridSpacing:[[_tmpDict objectForKey:@"Grid Spacing"] floatValue]];
		[_drawingView setGridTickCount:[[_tmpDict objectForKey:@"Grid Tick Count"] intValue]];
		[_drawingView setSnapToGrid:[[_tmpDict objectForKey:@"Snap to grid"] boolValue]];
		[_drawingView setShowRulers:[[_tmpDict objectForKey:@"Show Rulers"] boolValue]];
		 	
   		[_layerController updateLayersRender];
		[_drawingView setNeedsDisplay:YES];
		
		[_tmpDict release];
		_tmpDict = nil;
	}else if(_tmpImage){
		[[[_layerController layers] objectAtIndex:0] setBackgroundImage:_tmpImage];
	    [_drawingView setCanevasWidth:[_tmpImage size].width];
		[_drawingView setCanevasHeight:[_tmpImage size].height];
		
	
		[_tmpImage release];
		_tmpImage = nil;
	}else if(_tmpLayers){
		[_layerController setLayers:_tmpLayers];                     
		
		[_tmpLayers release];
	}
	
	[self updateChangeCount:NSChangeCleared];	
    
	[[NSNotificationCenter defaultCenter] addObserver:self
       										 selector:@selector(didUndo:) 
												 name:DBUndoManagerDidUndoChangeNotification 
											   object:_undoMngr];

	[[NSNotificationCenter defaultCenter] addObserver:self
	      										 selector:@selector(didRedo:) 
												 name:DBUndoManagerDidRedoChangeNotification 
											   object:_undoMngr];

	[[NSNotificationCenter defaultCenter] addObserver:self
	      										 selector:@selector(actionsDidChange:) 
												 name:DBUndoManagerUndoActionsDidChange 
											   object:_undoMngr];
	
}   

- (DBDrawingView *)drawingView
{
	return _drawingView;
} 

- (DBLayerController *)layerController
{
	return _layerController;
}

- (DBUndoManager *)specialUndoManager
{
	return _undoMngr;
}

- (id)valueForUndefinedKey:(NSString *)key
{
	return nil;
}

- (IBAction)export:(id)sender
{
	_currentExportPanel = [NSSavePanel savePanel];
	
	[self exportAccessoryViewPopupFormatDidChange:_exportFormatPopUp];
	[_currentExportPanel setCanSelectHiddenExtension:YES];
	[_currentExportPanel setCanCreateDirectories:YES];
	[_currentExportPanel setAccessoryView:_exportAccessoryView];
	[_currentExportPanel setExtensionHidden:NO];
	[_currentExportPanel beginSheetForDirectory:nil 
										   file:@"Untitled" 
								 modalForWindow:[_drawingView window] 
								  modalDelegate:self 
								 didEndSelector:@selector(exportChooseFileDidEnd:returnCode:contextInfo:)
									contextInfo:NULL];
	
}

- (void)exportChooseFileDidEnd:(NSSavePanel*)sheet returnCode:(int)code contextInfo:(void*)contextInfo
{
	if(code == NSCancelButton) return;
	
	NSString* format = [DBDocument formatForTag:[[_exportFormatPopUp selectedItem] tag]];
	BOOL success;                
	
	if([[_exportFormatPopUp selectedItem] tag]== 7){ // SVG format
		NSData *data;
		data = [[self SVGString] dataUsingEncoding:NSUTF8StringEncoding];
		
		success = [data writeToURL:[sheet URL] atomically:YES];
	}else{
		NSData *fileData = [_drawingView dataWithFormat:[format lowercaseString] jpegCompression:[_jpgQualitySlider floatValue]];
	//	fileData = [_drawingView dataWithPDFInsideRect:[_drawingView bounds]];
		//NSLog(@"fileData : %@",fileData);
		success = [fileData writeToFile:[sheet filename] atomically:YES];
	}
		
	if(!success)
		NSBeep();
}

- (IBAction)exportAccessoryViewPopupFormatDidChange:(id)sender
{
	NSString* format = [DBDocument formatForTag:[[_exportFormatPopUp selectedItem] tag]];
	[_currentExportPanel setRequiredFileType:[format lowercaseString]];
	
	if([[_exportFormatPopUp selectedItem] tag] == 4){
		[_jpgQualitySlider setEnabled:YES];
	}else{
		[_jpgQualitySlider setEnabled:NO];
	}                                      
	
}

- (IBAction)import:(id)sender
{
	NSOpenPanel *importPanel;
	
	importPanel = [NSOpenPanel openPanel];
	
	[importPanel beginSheetForDirectory:nil
										   file:nil
										  types:[NSImage imageFileTypes]
								 modalForWindow:[_drawingView window] 
								  modalDelegate:self
								 didEndSelector:@selector(importChooseFileDidEnd:returnCode:contextInfo:)
								   	contextInfo:NULL];	
}

- (void)importChooseFileDidEnd:(NSOpenPanel*)sheet returnCode:(int)code contextInfo:(void*)contextInfo
{
	if(code == NSCancelButton) return;
	                                                                                       
	NSImage *image;
	NSURL *url;
	
	url = [[sheet URLs] objectAtIndex:0];
	
	image = [[NSImage alloc] initByReferencingURL:url];
		
	if(image){
		[_layerController addImageToCurrentLayer:image];
	}else{
		NSBeep();
	}
	
	[image release];
}

- (void)printDocument:(id)sender {
    // Assume documentView returns the custom view to be printed
	NSPrintInfo *pi = [self printInfo];
	[pi setLeftMargin:0.0];
	[pi setRightMargin:0.0];
	[pi setTopMargin:0.0];
	[pi setBottomMargin:0.0];
	[self setPrintInfo:pi];
	
	NSPrintOperation *op = [NSPrintOperation
                printOperationWithView:_drawingView
                printInfo:[self printInfo]];
    [op runOperationModalForWindow:[_drawingView window]
                delegate:self
                didRunSelector:
                    @selector(printOperationDidRun:success:contextInfo:)
                contextInfo:NULL];
}
 
- (void)printOperationDidRun:(NSPrintOperation*)printOperation
                     success:(BOOL)success
                 contextInfo:(void*)info
{
    if (success) {
        // Can save updated NSPrintInfo, but only if you have
        // a specific reason for doing so
        // [self setPrintInfo: [printOperation printInfo]];
    }
}

- (void)undoDocument:(id)sender
{
    if([_undoMngr canUndo]){
		[_undoMngr undo];
    }
}   

- (void)redoDocument:(id)sender
{
    if([_undoMngr canRedo]){
		[_undoMngr redo];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	if([item action] == @selector(undoDocument:)){
		[item setTitle:[_undoMngr undoMenuItemTitle]];
		return [_undoMngr canUndo];
	}else if([item action] == @selector(redoDocument:)){
		[item setTitle:[_undoMngr redoMenuItemTitle]];
	    return [_undoMngr canRedo];
    }else{
		return [super validateMenuItem:item];
	}
}

- (void)didUndo:(NSNotification *)note
{
	[self updateChangeCount:NSChangeUndone];
}

- (void)didRedo:(NSNotification *)note
{
	[self updateChangeCount:NSChangeDone];	
}

- (void)actionsDidChange:(NSNotification *)note
{
	int i;
    [self updateChangeCount:NSChangeCleared];	

	for( i = 0; i < [_undoMngr undoCount]; i++ )
	{
		[self updateChangeCount:NSChangeDone];	
	}
}

@end
