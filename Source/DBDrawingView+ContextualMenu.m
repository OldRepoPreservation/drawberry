//
//  DBDrawingView+ContextualMenu.m
//  DrawBerry
//
//  Created by Raphael Bost on 15/04/12.
//  Copyright 2012 Ecole Polytechnique. All rights reserved.
//

#import "DBDrawingView+ContextualMenu.h"


@implementation DBDrawingView (ContextualMenu)
+ (NSMenu *)defaultMenu {
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];

    [menu addItemWithTitle:@"Undo" action:@selector(undoDocument:) keyEquivalent:@"z"];
    [menu addItemWithTitle:@"Redo" action:@selector(redoDocument:) keyEquivalent:@"Z"];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Delete Shape",nil) action:@selector(delete:) keyEquivalent:@"←"];
    
    return menu;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {

    return [[self class] defaultMenu];
}



@end
