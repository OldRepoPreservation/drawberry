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

/*- (NSSize)cellSize
{              
//	NSLog(@"cellSize object : %@", [[self objectValue] objectForKey:@"View"]);
	return [[[self objectValue] objectForKey:@"View"] frame].size;
}*/                                                               

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

                                                          
//	NSLog(@"control view %@", controlView);
//	NSLog(@"frames : %@, %@, %@", NSStringFromRect(cellFrame), NSStringFromRect([view frame]), NSStringFromRect([controlView bounds]));
	
}

/*- (void)setObjectValue:(id)value
{
	NSView * view = [[self objectValue] objectForKey:@"View"];
	
	if(!value){
		[view removeFromSuperview];
		NSLog(@"set nil");
	}
	
	[super setObjectValue:value];
} */
 
- (BOOL)collapsed
{
	return [[[self objectValue] objectForKey:@"View"] collapsed];
}

- (void)setCollapsed:(BOOL)newCollapsed
{
	[[[self objectValue] objectForKey:@"View"] setCollapsed:newCollapsed];
}

@end
