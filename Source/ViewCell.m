//
//  ViewCell.m
//  FunHouse
//
//  Created by Raphael Bost on 16/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViewCell.h"


@implementation ViewCell
// Constructor.
- (id) init
{
	self = [super initImageCell: nil];

	return self;
}                                                            

// Draw the cell.
- (void) drawInteriorWithFrame : (NSRect) cellFrame 
	inView: (NSView *) controlView
{
	NSView * view = [[self objectValue] objectForKey:@"View"];

	//     if(view != _view){
	//     	[_view removeFromSuperview];
	// 	_view = view;
	// }

	if(!view){
		[_view removeFromSuperview];
	}
	if([view superview] != controlView){
		[view removeFromSuperview];
		[controlView addSubview: view];
    }
    _view = view;
	                 
	[view setFrame: cellFrame];

                                                          	
}

- (BOOL)collapsed
{
	return [[[self objectValue] objectForKey:@"View"] collapsed];
}

- (void)setCollapsed:(BOOL)newCollapsed
{
	[[[self objectValue] objectForKey:@"View"] setCollapsed:newCollapsed];
}

@end
