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
#import <GradientPanelFramework/GPGradientPanelFramework.h>

#import "DBFill.h"
                          
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
	NSString *frame;

	// setup inspector windows    

	[_viewInspector setFrameAutosaveName:@"gridWindow"];
	[_viewInspector setMinFrameAnimate:NO];
	frame = [_viewInspector stringWithSavedFrame];

 	[_viewInspector addView:_gridView title:NSLocalizedString(@"Grid",nil) collapsed:YES];
	[_viewInspector addView:_canevasView title:NSLocalizedString(@"Page",nil) collapsed:YES];   
	[_viewInspector addView:_rulerView title:NSLocalizedString(@"Rulers",nil) collapsed:YES];
	[_viewInspector updateViewList];
	[_viewInspector setFrameFromString:frame];
	
	
	
	[_objectInspector setFrameAutosaveName:@"shapeWindow"];
	[_objectInspector setMinFrameAnimate:NO];
	frame = [_objectInspector stringWithSavedFrame];
	
	[_objectInspector addView:_strokeView title:NSLocalizedString(@"Stroke",nil) collapsed:YES];
	[_objectInspector addView:_arrowView title:NSLocalizedString(@"Arrows",nil) collapsed:YES];
	[_objectInspector addView:_fillView title:NSLocalizedString(@"Fill",nil) collapsed:YES];
	[_objectInspector addView:_shadowView title:NSLocalizedString(@"Shadow",nil) collapsed:YES];
	[_objectInspector addView:_textView title:NSLocalizedString(@"Text",nil) collapsed:YES];
	[_objectInspector addView:_geometryView title:NSLocalizedString(@"Geometry",nil) collapsed:YES];
	[_objectInspector updateViewList];
	
	[_objectInspector setFrameFromString:frame];

    
	[_fillGradientWell bind:@"gradient" toObject:_fillController withKeyPath:@"selection.gradient" options:nil];
	[_fillGradientWell bind:@"gradientAngle" toObject:_fillController withKeyPath:@"selection.gradientAngle" options:nil];
	[_fillGradientWell bind:@"gradientType" toObject:_fillController withKeyPath:@"selection.gradientType" options:nil];
	
	[_shadowControl bind:@"shadowOffsetWidth" toObject:_shadowController withKeyPath:@"selection.shadowOffsetWidth" options:nil];
	[_shadowControl bind:@"shadowOffsetHeight" toObject:_shadowController withKeyPath:@"selection.shadowOffsetHeight" options:nil];
	[_shadowControl bind:@"shadowBlurRadius" toObject:_shadowController withKeyPath:@"selection.shadowBlurRadius" options:nil];
	[_shadowControl bind:@"shadowColor" toObject:_shadowController withKeyPath:@"selection.shadowColor" options:nil];

	[_fillGradientWell addObserver:self 
						forKeyPath:@"gradient" 
						   options:NSKeyValueObservingOptionNew 
						   context:nil];

	[_fillGradientWell addObserver:self 
						forKeyPath:@"gradientAngle" 
						   options:NSKeyValueObservingOptionNew 
						   context:nil];

	[_fillGradientWell addObserver:self 
						forKeyPath:@"gradientType" 
						   options:NSKeyValueObservingOptionNew 
						   context:nil];
}  

- (void)dealloc
{	
	[_fillGradientWell removeObserver:self forKeyPath:@"gradient"];
	[_fillGradientWell removeObserver:self forKeyPath:@"gradientAngle"];
	[_fillGradientWell removeObserver:self forKeyPath:@"gradientType"];
	
	[super dealloc];
}

- (id)applicationController
{
	return [NSApp delegate];
}

- (void)appWillTerminate:(NSNotification *)note
{
}

- (IBAction)action:(id)sender
{
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
		[[_fillController content] setGradient:[_fillGradientWell gradient]];
//		[[_fillController content] setGradientAngle:[_fillGradientWell gradientAngle]];
	}else if([keyPath isEqualTo:@"gradientAngle"]){
//		[[_fillController content] setGradientAngle:[_fillGradientWell gradientAngle]];
	}else if([keyPath isEqualTo:@"gradientType"]){
//		[[_fillController content] setGradientType:[_fillGradientWell gradientType]];
	}
}
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

- (IBAction)takeGradientFrom:(id)sender
{
	[[_fillController content] setGradient:[_fillGradientWell gradient]];
	[[_fillController content] setGradientAngle:-[(GPGradientWell *) _fillGradientWell gradientAngle]];
	[[_fillController content] setGradientType:[(GPGradientWell *) _fillGradientWell gradientType]];
}
@end
