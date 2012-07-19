//
//  DBGroupsWindowController.m
//  DrawBerry
//
//  Created by Raphael Bost on 19/07/12.
//  Copyright 2012 Ecole Polytechnique. All rights reserved.
//

#import "DBGroupsWindowController.h"

static DBGroupsWindowController *_sharedGroupsWindowController = nil;

@implementation DBGroupsWindowController

+ (id)sharedGroupsWindowController {
    if (!_sharedGroupsWindowController) {
        _sharedGroupsWindowController = [[DBGroupsWindowController allocWithZone:[self zone]] init];
    }
    return _sharedGroupsWindowController;
} 

- (id)init {
    self = [self initWithWindowNibName:@"DBGroups"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBGroups"];
    }
    return self;
} 
- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[self window] setFrameAutosaveName:@"layerWindow"];

}

@end
