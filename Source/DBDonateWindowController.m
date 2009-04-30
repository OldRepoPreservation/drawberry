//
//  DBDonateWindowController.m
//  DrawBerry
//
//  Created by Raphael Bost on 26/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DBDonateWindowController.h"


@implementation DBDonateWindowController
+ (void)initialize
{	
	NSMutableDictionary *defaultValues = [[NSMutableDictionary alloc] init];
	
   	[defaultValues setObject:[NSNumber numberWithFloat:0.0f] forKey:@"Donate Reminder Version"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
	[defaultValues release];	
}

- (id)init 
{
    self = [self initWithWindowNibName:@"DBDonatePanel"];
    if (self) {                                 

    }
    return self;
}

- (void)awakeFromNib
{
//	[self showDonateWindowIfNecessary];
}

- (void)showDonateWindowIfNecessary
{

	float version, reminderVersion;
	
	version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
	reminderVersion = [[NSUserDefaults standardUserDefaults] floatForKey:@"Donate Reminder Version"];

	if(version > reminderVersion){
		[self showWindow:self];
	}
}

- (void)updateReminderVersion
{
	float version;
	version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
	
	[[NSUserDefaults standardUserDefaults] setFloat:version	forKey:@"Donate Reminder Version"];
}

- (IBAction)donate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"Donate" ofType:@"webloc"]];
	[[self window] orderOut:sender];
}

- (IBAction)alreadyDonated:(id)sender
{
	[self updateReminderVersion];
	[[self window] orderOut:sender];
}
@end
