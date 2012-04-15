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
    [menu addItemWithTitle:NSLocalizedString(@"Copy",nil) action:@selector(copy:) keyEquivalent:@"c"];
    [menu addItemWithTitle:NSLocalizedString(@"Cut",nil) action:@selector(cut:) keyEquivalent:@"x"];
    [menu addItemWithTitle:NSLocalizedString(@"Paste",nil) action:@selector(paste:) keyEquivalent:@"v"];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Duplicate",nil) action:@selector(duplicate:) keyEquivalent:@"d"];
    [menu addItemWithTitle:NSLocalizedString(@"Delete",nil) action:@selector(delete:) keyEquivalent:@"←"];
    
    return menu;
}

+ (NSMenu *)booleanOpsMenu
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Boolean Operations Menu"] autorelease];

    [menu addItemWithTitle:NSLocalizedString(@"Union", nil) action:@selector(unionSelectedObjects:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Diff", nil) action:@selector(diffSelectedObjects:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Intersection", nil) action:@selector(intersectionSelectedObjects:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"XOR", nil) action:@selector(xorSelectedObjects:) keyEquivalent:@""];
    
    return menu;
}

+ (NSMenu *)alignMenu
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Alignment Menu"] autorelease];
    
    [menu addItemWithTitle:NSLocalizedString(@"Left", nil) action:@selector(alignLeft:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Center", nil) action:@selector(alignCenter:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Right", nil) action:@selector(alignRight:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Top", nil) action:@selector(alignTop:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Middle", nil) action:@selector(alignMiddle:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Bottom", nil) action:@selector(alignBottom:) keyEquivalent:@""];

    return menu;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {

    NSMenu *menu = [[self class] defaultMenu];
    
    if([_selectedShapes count] > 1){
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *alignItem, *boolOpsItem;
        
        boolOpsItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Boolean Ops", nil) action:nil keyEquivalent:@""] autorelease];
        alignItem = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Align ...", nil) action:nil keyEquivalent:@""] autorelease];
        
        [boolOpsItem setSubmenu:[[self class] booleanOpsMenu]];
        [alignItem setSubmenu:[[self class] alignMenu]];
        
        [menu addItem:boolOpsItem];
        [menu addItem:alignItem];
    }
    
    return menu;
}



@end
