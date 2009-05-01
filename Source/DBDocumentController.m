//
//  DBDocumentController.m
//  DrawBerry
//
//  Created by Raphael Bost on 26/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DBDocumentController.h"

#import "DBTemplateManager.h"
#import "DBPrefController.h"

@implementation DBDocumentController
- (void)awakeFromNib
{
	[DBTemplateManager sharedTemplateManager]; // be sure to initialize the template manager

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(templateMenuDidChange:) name:DBTemplateMenuDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeFieldDidChange:) name:NSControlTextDidChangeNotification object:_widthField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeFieldDidChange:) name:NSControlTextDidChangeNotification object:_heightField];
	
	[self updateTemplateMenuChooser];
}
- (IBAction)newDocument:(id)sender
{
	[_newPanel makeKeyAndOrderFront:sender];
}

- (IBAction)openDocument:(id)sender
{
	[_newPanel orderOut:sender];
	[super openDocument:sender];
}

- (IBAction)changeSize:(id)sender
{
	NSLog(@"change");
	_docWidth = [_widthField floatValue];
	_docHeight = [_heightField floatValue];
}

- (IBAction)changeTemplate:(id)sender
{
	int tag;
	
	tag = [_templateChooser selectedTag];
	if(tag != 1000 && tag != 999){
		NSSize size;
		
		size = [[DBTemplateManager sharedTemplateManager] sizeForTemplateTag:[_templateChooser selectedTag]];
		
		[_widthField setFloatValue:size.width];
		[_heightField setFloatValue:size.height];
		
		_docWidth = size.width;
		_docHeight = size.height;
		
	}else if(tag == 999){
		// open prefs ...
		[[DBPrefController sharedPrefController] showWindow:self];
	}
}

- (IBAction)create:(id)sender
{
	[_newPanel orderOut:sender];
	[super newDocument:sender];
}

- (float)documentWidth
{
	return _docWidth;
}

- (float)documentHeight
{
	return _docHeight;
}


- (void)updateTemplateMenuChooser
{
	NSMenu *m;
	NSMenuItem *item;
	
	m = [[[DBTemplateManager sharedTemplateManager] templatesMenu] copy];
	
	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Add ...",nil) action:nil keyEquivalent:@""];
	[item setTag:999];
	[m addItem:item];
	[item release];

	[m addItem:[NSMenuItem separatorItem]];

	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Custom",nil) action:nil keyEquivalent:@""];
	[item setTag:1000];
	[m addItem:item];
	[item release];
	
	[_templateChooser setMenu:m];
	
	[m release];	
}

- (void)templateMenuDidChange:(NSNotification *)note
{
	[self updateTemplateMenuChooser];
}

- (void)sizeFieldDidChange:(NSNotification *)note
{
	[_templateChooser selectItemWithTag:1000]; // select "Custom" item
}

@end
