//
//  DBToolMatrix.m
//  DrawBerry
//
//  Created by Raphael Bost on 12/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBToolMatrix.h"
#import "DBButtonCell.h"

#import "DBPrefKeys.h"


@implementation DBToolMatrix

- (id)initWithFrame:(NSRect)frameRect
{
	NSLog(@"init");
	self = [super initWithFrame:frameRect];

	[self setCellClass:[DBButtonCell class]];
		
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	[self setCellClass:[DBButtonCell class]];
	            
	return self;
}

- (Class)cellClass
{
	return [DBButtonCell class];
}

- (NSCell *)cellAtPoint:(NSPoint)p	
{
		int i, j;
		[self getRow:&j column:&i forPoint:p];
		return [self cellAtRow:j column:i];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	_double = NO;
	[[self selectedCell] setLocked:NO];
	[super mouseDown:theEvent];

	NSPoint p;
	NSCell *cell;
	p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	cell = [self cellAtPoint:p];                        
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:DBToolSelectorMode] == 0)
	{
    	[(DBButtonCell *)cell setHighlighted:YES];  	
		[(DBButtonCell *)cell setLocked:YES];  			
	}
	if([theEvent clickCount] > 1){
		_double = YES;
		
    	[(DBButtonCell *)cell setHighlighted:YES];  	
		[(DBButtonCell *)cell setLocked:YES];  	
	}
	if([cell tag] == 0){
		[(DBButtonCell *)cell setHighlighted:YES];
		[(DBButtonCell *)cell setLocked:YES];  	
	}		
	
}   

// - (void)mouseUp:(NSEvent *)theEvent
// {
// 	NSPoint p;
// 	NSCell *cell;
// 	p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
// 	cell = [self cellAtPoint:p];                        
// 	
// 	[super mouseUp:theEvent];
// 	
// 	NSLog(@"double : %d", _double);
// 	if(_double){
// 		[cell setHighlighted:YES];
// 	}
// }

- (void)toolDidEnd:(id)sender
{
	if(![[self selectedCell] isLocked] && [[NSUserDefaults standardUserDefaults] integerForKey:DBToolSelectorMode] == 1){
		[self selectCellWithTag:0];
		[[self cellWithTag:0] setHighlighted:YES];
		[[self cellWithTag:0] setLocked:YES];
	}  		
}

@end
