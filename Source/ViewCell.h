//
//  ViewCell.h
//  FunHouse
//
//  Created by Raphael Bost on 16/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Some handy definitions.
#define kView @"view"

// An NSCell that contains a progress indicator.
@interface ViewCell : NSCell
{
	BOOL _collapsed; 
	NSView *_view;
}

// Initialize.
- (id) init;

// Draw the cell.
- (void) drawInteriorWithFrame : (NSRect) cellFrame 
  inView: (NSView *) controlView;

- (BOOL)collapsed;
- (void)setCollapsed:(BOOL)newCollapsed;

@end