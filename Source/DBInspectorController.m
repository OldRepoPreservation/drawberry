//
//  DBInspectorController.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBInspectorController.h"

#import "GInspectWindow.h"
#import <GradientPanel/GradientPanel.h>
                          
static DBInspectorController *_sharedInspectorController = nil;

@implementation DBInspectorController
+ (id)sharedInspectorController 
{
    if (!_sharedInspectorController) {
        _sharedInspectorController = [[DBInspectorController allocWithZone:[self zone]] init];
    }
    return _sharedInspectorController;
}

- (id)init 
{
    self = [self initWithWindowNibName:@"DBInspector"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBInspector"];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:NSApplicationWillTerminateNotification object:NSApp];
    }
    return self;
}

- (void)awakeFromNib
{
	// setup inspector windows    
	[_viewInspector setMinFrameAnimate:NO];

//	[_viewInspector setMiniwindowImage:[NSImage imageNamed:@"page"]];
//	[[_viewInspector standardWindowButton:NSWindowDocumentIconButton] setImage:[NSImage imageNamed:@"page"]];

 	[_viewInspector addView:_gridView title:NSLocalizedString(@"Grid",nil) collapsed:YES];
	[_viewInspector addView:_canevasView title:NSLocalizedString(@"Page",nil) collapsed:YES];   
	[_viewInspector addView:_rulerView title:NSLocalizedString(@"Rulers",nil) collapsed:YES];
	
	[_viewInspector setFrameAutosaveName:@"gridWindow"];
	
	
	[_objectInspector setMinFrameAnimate:NO];
	[_objectInspector setMiniwindowImage:[NSImage imageNamed:@"shape"]];
	[_objectInspector addView:_strokeView title:NSLocalizedString(@"Stroke",nil) collapsed:YES];
	[_objectInspector addView:_arrowView title:NSLocalizedString(@"Arrows",nil) collapsed:YES];
	[_objectInspector addView:_fillView title:NSLocalizedString(@"Fill",nil) collapsed:YES];
	[_objectInspector addView:_shadowView title:NSLocalizedString(@"Shadow",nil) collapsed:YES];
	[_objectInspector addView:_textView title:NSLocalizedString(@"Text",nil) collapsed:YES];
	[_objectInspector addView:_geometryView title:NSLocalizedString(@"Geometry",nil) collapsed:YES];
	
	[_objectInspector setFrameAutosaveName:@"shapeWindow"];
    
	[_fillGradientWell bind:@"gradient" toObject:_fillController withKeyPath:@"selection.gradient" options:nil];
	
	[_shadowControl bind:@"shadowOffsetWidth" toObject:_shadowController withKeyPath:@"selection.shadowOffsetWidth" options:nil];
	[_shadowControl bind:@"shadowOffsetHeight" toObject:_shadowController withKeyPath:@"selection.shadowOffsetHeight" options:nil];
	[_shadowControl bind:@"shadowBlurRadius" toObject:_shadowController withKeyPath:@"selection.shadowBlurRadius" options:nil];
	[_shadowControl bind:@"shadowColor" toObject:_shadowController withKeyPath:@"selection.shadowColor" options:nil];

/*	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:_viewInspector];
 
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:_objectInspector];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillOpen:) 
												 name:NSWindowDidBecomeKeyNotification 
											   object:_viewInspector];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(inspectorWindowWillOpen:) 
												 name:NSWindowDidBecomeKeyNotification 
											   object:_objectInspector];
*/

	[_fillGradientWell addObserver:self 
				forKeyPath:@"gradient" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
				
//	[_shadowControl setTarget:self];
//	[_shadowControl setAction:@selector(shadowAction:)];
	              
/*	NSRect frame = [[_inspectorSelector window] frame];
	frame.size = [_inspectorSelector frame].size;
	frame.size.height += 14;
	[[_inspectorSelector window] setFrame:frame display:YES animate:NO];
	[[_inspectorSelector cellWithTag:0] setState:NSOnState];
	[[_inspectorSelector cellWithTag:1] setState:NSOnState];
*/
//	[_strokeThickness setMinValue:1.0];
//	[_strokeThickness setMaxValue:32.0];

//	[_strokeThickness bind:@"value" toObject:_strokeController withKeyPath:@"selection.lineWidth" options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSConditionallySetsEditableBindingOption]];
}  

- (void)dealloc
{
	[_viewInspector collapseAllViews];
	[_objectInspector collapseAllViews];
	
	[super dealloc];
}

- (id)applicationController
{
	return [NSApp delegate];
}

- (void)appWillTerminate:(NSNotification *)note
{
	[_viewInspector collapseAllViews];
	[_objectInspector collapseAllViews];	
}

- (IBAction)action:(id)sender
{
//	NSLog(@"image view : %@, %d, %d, %d", _imageView, [_imageView isEditable], [_imageView isHidden], [_imageView isEnabled]);
//	[_imageView setEditable:YES];
}

- (IBAction)chooseStrokeImage:(id)sender
{
	NSOpenPanel *op;
	int result;
	
	op = [NSOpenPanel openPanel];
	
	result = [op runModalForTypes:[NSImage imageFileTypes]];
	
	if(result == NSOKButton){
		NSImage *image = [[NSImage alloc] initByReferencingFile:[[op filenames] objectAtIndex:0] ];
		[_strokeImageView setImage:image];
		[[_strokeController content] setValue:image forKey:@"fillImage"];
		[image release];
	}
	
}

- (IBAction)chooseFillImage:(id)sender
{
	NSOpenPanel *op;
	int result;
	
	op = [NSOpenPanel openPanel];
	
	result = [op runModalForTypes:[NSImage imageFileTypes]];
	
	if(result == NSOKButton){
		NSImage *image = [[NSImage alloc] initByReferencingFile:[[op filenames] objectAtIndex:0] ];
		[_fillImageView setImage:image];
		[[_fillController content] setValue:image forKey:@"fillImage"];
		[image release];
	}
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	if([keyPath isEqualTo:@"gradient"]){
		[[_fillController content] setGradient:[_fillGradientWell objectValue]];
	}
}
/*
- (void)inspectorWindowWillClose:(NSNotification *)note
{
	NSWindow *window;
	window = [note object];
	int tag;
	
	if(window == _viewInspector){
		tag = 0;
	}else if(window == _objectInspector){
		tag = 1;
	}           
	
	[[_inspectorSelector cellWithTag:tag] setState:NSOffState];
	
//	[_inspectorSelector setSelected:NO forSegment:tag];
}

- (void)inspectorWindowWillOpen:(NSNotification *)note
{
	NSWindow *window;
	window = [note object];
	int tag;
	
	if(window == _viewInspector){
		tag = 0;
	}else if(window == _objectInspector){
		tag = 1;
	}           
	
	[[_inspectorSelector cellWithTag:tag] setState:NSOnState];
//	[_inspectorSelector setSelected:YES forSegment:tag];
}

- (IBAction)inspectorSelectorAction:(id)sender
{
 //   if([_inspectorSelector isSelectedForSegment:0] != [_viewInspector isVisible]){
   	if([[_inspectorSelector cellWithTag:0] state] != [_viewInspector isVisible]){
		if([[_inspectorSelector cellWithTag:0] state]){
			[_viewInspector makeKeyAndOrderFront:self];
		}else{
			[_viewInspector orderOut:self];
		}
	}

	if([[_inspectorSelector cellWithTag:1] state] != [_objectInspector isVisible]){
		if([[_inspectorSelector cellWithTag:1] state]){
			[_objectInspector makeKeyAndOrderFront:self];
		}else{
			[_objectInspector orderOut:self];
		}
	}
}
*/
- (NSWindow *)viewInspector
{
	return _viewInspector;
}
- (NSWindow *)objectInspector
{
	return _objectInspector;
}

- (IBAction)shadowAction:(id)sender
{
	id shadow;
	shadow = [_shadowController content];
	
	[shadow setValue:[_shadowControl valueForKey:@"shadowOffsetWidth"] forKey:@"shadowOffsetWidth"];
	[shadow setValue:[_shadowControl valueForKey:@"shadowOffsetHeight"] forKey:@"shadowOffsetHeight"];
	[shadow setValue:[_shadowControl valueForKey:@"shadowBlurRadius"] forKey:@"shadowBlurRadius"];
	[shadow setValue:[_shadowControl valueForKey:@"shadowColor"] forKey:@"shadowColor"];
}

- (IBAction)flipText:(id)sender
{                                  
	[[_strokeController content] setValue:[NSNumber numberWithBool:NO] forKey:@"toggleFlipText"];
}
@end
