//
//  DBInspectorController.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBInspectorController.h"

#import "GInspectWindow.h"
//#import <GradientPanel/GradientPanel.h>
#import <GradientPanelFramework/GPGradientPanelFramework.h>

#import "DBFill.h"
  
#import "DBPrefKeys.h"

static DBInspectorController *_sharedInspectorController = nil;

@implementation DBInspectorController
+ (void)initialize
{
	NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];

   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBPagePanelGridCollapsed];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBPagePanelPageCollapsed];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBPagePanelRulersCollapsed];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBShapePanelRulersCollapsed];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBShapePanelArrowsCollapsed];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBShapePanelFillCollapsed];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBShapePanelShadowCollapsed];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBShapePanelTextCollapsed];
   	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DBShapePanelGeometryCollapsed];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
	[defaultValues release];	
}
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
	
 	[_viewInspector addView:_gridView title:@"Grid" collapsed:YES];
	[_viewInspector addView:_canevasView title:@"Page" collapsed:YES];   
	[_viewInspector addView:_rulerView title:@"Rulers" collapsed:YES];
	[_viewInspector updateViewList];
	[_viewInspector updateWindowPosition];
	
	
	[_objectInspector setFrameAutosaveName:@"shapeWindow"];
	[_objectInspector setMinFrameAnimate:NO];
	
	[_objectInspector addView:_strokeView title:@"Stroke" collapsed:YES];
	[_objectInspector addView:_arrowView title:@"Arrows" collapsed:YES];
	[_objectInspector addView:_fillView title:@"Fill" collapsed:YES];
	[_objectInspector addView:_shadowView title:@"Shadow" collapsed:YES];
	[_objectInspector addView:_textView title:@"Text" collapsed:YES];
	[_objectInspector addView:_geometryView title:@"Geometry" collapsed:YES];
	[_objectInspector updateViewList];
	
	[_objectInspector updateWindowPosition];

    
	[_fillGradientWell bind:@"gradient" toObject:_fillsController withKeyPath:@"selection.gradient" options:nil];
	[_fillGradientWell bind:@"gradientAngle" toObject:_fillsController withKeyPath:@"selection.gradientAngle" options:nil];
	[_fillGradientWell bind:@"gradientType" toObject:_fillsController withKeyPath:@"selection.gradientType" options:nil];
	
	
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
		[[[_fillsController selectedObjects] objectAtIndex:0] setValue:image forKey:@"fillImage"];
		[image release];
	}
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	if([keyPath isEqualTo:@"gradient"]){
		if([[_fillsController selectedObjects] count] >0 )
			[(DBFill *)[[_fillsController selectedObjects] objectAtIndex:0] setGradient:[(GPGradientWell *)_fillGradientWell gradient]];
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

	if(sender == _shadowControl){ // update the shadows infos	
        [shadow setValue:[_shadowControl valueForKey:@"shadowOffsetWidth"] forKey:@"shadowOffsetWidth"];
        [shadow setValue:[_shadowControl valueForKey:@"shadowOffsetHeight"] forKey:@"shadowOffsetHeight"];
        [shadow setValue:[_shadowControl valueForKey:@"shadowBlurRadius"] forKey:@"shadowBlurRadius"];
        [shadow setValue:[_shadowControl valueForKey:@"shadowColor"] forKey:@"shadowColor"];
    }else{ // update the shadow control
        [_shadowControl setValue:[shadow valueForKey:@"shadowOffsetWidth"] forKey:@"shadowOffsetWidth"];
        [_shadowControl setValue:[shadow valueForKey:@"shadowOffsetHeight"] forKey:@"shadowOffsetHeight"];
        [_shadowControl setValue:[shadow valueForKey:@"shadowBlurRadius"] forKey:@"shadowBlurRadius"];
        [_shadowControl setValue:[shadow valueForKey:@"shadowColor"] forKey:@"shadowColor"];
    }
}

- (IBAction)flipText:(id)sender
{                                  
	[[_strokeController content] setValue:[NSNumber numberWithBool:NO] forKey:@"toggleFlipText"];
}

- (IBAction)clearText:(id)sender
{
    [[_strokeController content] clearText];
}

- (IBAction)takeGradientFrom:(id)sender
{
	[(DBFill *)[[_fillsController selectedObjects] objectAtIndex:0] setGradient:[(GPGradientWell *)_fillGradientWell gradient]];
	[[[_fillsController selectedObjects] objectAtIndex:0] setGradientAngle:-[(GPGradientWell *) _fillGradientWell gradientAngle]];
	[[[_fillsController selectedObjects] objectAtIndex:0] setGradientType:[(GPGradientWell *) _fillGradientWell gradientType]];
}
@end