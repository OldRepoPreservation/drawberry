//
//  DBPrefController.m
//  DrawBerry
//
//  Created by Raphael Bost on 16/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBPrefController.h"
#import "DBPrefKeys.h"

static DBPrefController *_sharedPrefController = nil;

@implementation DBPrefController

+ (id)sharedPrefController
{
    if (!_sharedPrefController) {
        _sharedPrefController = [[DBPrefController allocWithZone:[self zone]] init];
    }
    return _sharedPrefController;	
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
@end
