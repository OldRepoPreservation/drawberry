//
//  DBPrefController.m
//  DrawBerry
//
//  Created by Raphael Bost on 16/07/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBPrefController.h"
#import "DBPrefKeys.h"

#import "DBTemplateManager.h"

static DBPrefController *_sharedPrefController = nil;

@implementation DBPrefController

+ (id)sharedPrefController
{
    if (!_sharedPrefController) {
        _sharedPrefController = [[DBPrefController allocWithZone:[self zone]] init];
    }
    return _sharedPrefController;	
}

+ (NSString *)applicationSupportFolder 
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"DrawBerry"];
}

- (id)init
{
	self = [self initWithWindowNibName:@"DBPreferences"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBPreferences"];
    }
    return self;
}

- (void)awakeFromNib
{   
	[_toolModeSelector selectItemWithTag:[[NSUserDefaults standardUserDefaults] integerForKey:DBToolSelectorMode]];
	[_unitSelector selectItemWithTag:[[NSUserDefaults standardUserDefaults] integerForKey:DBUnitName]];
	
	[_openEmptyDocAtStartupCheckBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:DBNewDocumentAtStartup]];
}
- (IBAction)changeToolSelectionMode:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[_toolModeSelector selectedItem] tag]] forKey:DBToolSelectorMode];
}


- (IBAction)changeUnit:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[_unitSelector selectedItem] tag]] forKey:DBUnitName];

	[[NSNotificationCenter defaultCenter] postNotificationName:DBDidChangeUnitNotificationName	object:self];
}


#pragma mark Templates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[[DBTemplateManager sharedTemplateManager] customTemplates] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSDictionary *template;
	
	template = [[DBTemplateManager sharedTemplateManager] customTemplateForTag:rowIndex];
	
	if(!template){
		return nil;
	}
	
	if([[aTableColumn identifier] isEqualTo:@"Name"]){
		return [template objectForKey:@"Name"];
	}else if([[aTableColumn identifier] isEqualTo:@"Width"]){
		return [NSNumber numberWithFloat:NSSizeFromString([template objectForKey:@"Size"]).width];
	}else if([[aTableColumn identifier] isEqualTo:@"Height"]){
		return [NSNumber numberWithFloat:NSSizeFromString([template objectForKey:@"Size"]).height];
	}
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSDictionary *template;
	
	template = [[DBTemplateManager sharedTemplateManager] customTemplateForTag:rowIndex];
		
	if([[aTableColumn identifier] isEqualTo:@"Name"]){
		[[DBTemplateManager sharedTemplateManager] setName:anObject forCustomTemplateAtTag:rowIndex];
	}else if([[aTableColumn identifier] isEqualTo:@"Width"]){
		[[DBTemplateManager sharedTemplateManager] setWidth:[anObject floatValue] forCustomTemplateAtTag:rowIndex];
	}else if([[aTableColumn identifier] isEqualTo:@"Height"]){
		[[DBTemplateManager sharedTemplateManager] setHeight:[anObject floatValue] forCustomTemplateAtTag:rowIndex];
	}
}

- (IBAction)addTemplate:(id)sender{
	[[DBTemplateManager sharedTemplateManager] addUntitledTemplate];
	
	[_templatesView reloadData];
}

- (IBAction)removeTemplate:(id)sender
{
	[[DBTemplateManager sharedTemplateManager] removeCustomTemplateWithTag:[_templatesView selectedRow]];

	[_templatesView reloadData];
}

- (IBAction)changeDBNewDocumentAtStartup:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:[_openEmptyDocAtStartupCheckBox state] forKey:DBNewDocumentAtStartup];
}

@end
