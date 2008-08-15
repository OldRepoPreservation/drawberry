//
//  DBContextualBar.m
//  ContextualToolBar
//
//  Created by Raphael Bost on 24/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBContextualBar.h"


@implementation DBContextualBar

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_activeAnimation = [[NSViewAnimation alloc] init];
	    [_activeAnimation setDuration:0.25];
	    [_activeAnimation setAnimationCurve:NSAnimationEaseInOut]; 
		[_activeAnimation setAnimationBlockingMode:NSAnimationNonblocking];
		[_activeAnimation setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
	[_activeAnimation release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect 
{
    // Drawing code here.
//	[[NSColor redColor] set];
//	[[NSColor colorWithCalibratedRed:0.12549 green:0.12549 blue:0.12549 alpha:0.95] set];
//	[NSBezierPath fillRect:rect];
}

- (BOOL)isOpaque
{
	return NO;
}             

- (void)awakeFromNib
{
	[self reloadDataSource];
}

- (IBAction)close:(id)sender
{
    if(_state == 2 || _state == 3){
		return;
    }

    NSRect viewFrame; 
    NSRect newViewFrame; 
    NSMutableDictionary* viewDict;

//	[_activeAnimation setDuration:0.8];

    if([_activeAnimation isAnimating]){
//		NSLog(@"stop order");
		[_activeAnimation stopAnimation];
//		NSLog(@"stop effect");
	}

    // Create the attributes dictionary for the first view.
    viewDict = [NSMutableDictionary dictionaryWithCapacity:3];
    viewFrame = [self frame];

    // Specify which view to modify.
    [viewDict setObject:self forKey:NSViewAnimationTargetKey];

    // Specify the starting position of the view.
    [viewDict setObject:[NSValue valueWithRect:viewFrame] 
             forKey:NSViewAnimationStartFrameKey];

    // Change the ending position of the view.
    newViewFrame = viewFrame; 


    newViewFrame.origin.y = [[[self window] contentView] frame].size.height;
    [viewDict setObject:[NSValue valueWithRect:newViewFrame] 
             forKey:NSViewAnimationEndFrameKey]; 

    [_activeAnimation setViewAnimations:[NSArray arrayWithObjects:viewDict, nil]];

    // Run the animation.
	_state = 2;
    [_activeAnimation startAnimation];
}   

- (IBAction)open:(id)sender
{
	    if(_state == 1 || _state == 4){
			return;
	    }
		NSRect viewFrame; 
	    NSRect newViewFrame; 
	    NSMutableDictionary* viewDict;

//		[_activeAnimation setDuration:0.8];
		
        if([_activeAnimation isAnimating]){ 
			//NSLog(@"stop order");
			[_activeAnimation stopAnimation];
			//NSLog(@"stop effect");
		}	
        	
        // Create the attributes dictionary for the first view.
        viewDict = [NSMutableDictionary dictionaryWithCapacity:3];
        viewFrame = [self frame];

        // Specify which view to modify.
        [viewDict setObject:self forKey:NSViewAnimationTargetKey];

        // Specify the starting position of the view.
        [viewDict setObject:[NSValue valueWithRect:viewFrame] 
                 forKey:NSViewAnimationStartFrameKey];

        // Change the ending position of the view.
        newViewFrame = viewFrame; 

        newViewFrame.origin.y = [[[self window] contentView]  frame].size.height-viewFrame.size.height;
        [viewDict setObject:[NSValue valueWithRect:newViewFrame] 
                 forKey:NSViewAnimationEndFrameKey]; 
	    

	    [_activeAnimation setViewAnimations:[NSArray arrayWithObjects:viewDict, nil]];



	    // Run the animation.
		_state = 1;
	    [_activeAnimation startAnimation];
}

- (id <DBContextualBarDataSource>)dataSource
{
	return _dataSource;
}

- (void)setDataSource:(id <DBContextualBarDataSource>)newDataSource
{
	_dataSource = newDataSource;
	[self reloadDataSource];
}                           

- (IBAction)reload:(id)sender
{
	[self reloadDataSource];
}                           

- (void)reloadDataSource
{
	[[self subviews] makeObjectsPerformSelector:@selector(retain)];
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperviewWithoutNeedingDisplay)];
	
	int i;
	NSView *view;
	NSRect frame;
	float accumulatedWidth = 5.0f;
	float frameHeight = [self frame].size.height;

	for( i = 0; i < [_dataSource numberOfItems]; i++ )
	{                          
		view = [[_dataSource itemAtIndex:i] retain];
		[view removeFromSuperviewWithoutNeedingDisplay];	
		frame = [view frame];
		
		frame.origin.x = accumulatedWidth;
		frame.origin.y = (frameHeight - frame.size.height)/2;
		
		[view setFrame:frame];
		
		[self addSubview:view];
		                         
		accumulatedWidth += frame.size.width;
		accumulatedWidth += 5.0f;
		
		[view release];
	}
}

- (void)changeForDataSource:(id <DBContextualBarDataSource>)newDataSource animate:(BOOL)flag
{
	
	if(flag){
		_newDataSource = newDataSource;

		[self close:self];	                                   
		_state = 3;		
	}else{
		[self setDataSource:newDataSource];
	}
}

- (void)updateViewForDataSource
{
//	[self close:self];	                                   
//	_state = 4;		
	[self changeForDataSource:_dataSource animate:YES];
}   

- (void)animationDidEnd:(NSAnimation* )anim
{
	if(_state == 3){
		[self setDataSource:_newDataSource];
		_newDataSource = nil;
		                
		[self performSelector:@selector(open:) withObject:self afterDelay:FLT_MIN];
		
	}else if(_state == 4){
		[self reloadDataSource];
	    [self performSelector:@selector(open:) withObject:self afterDelay:FLT_MIN];
	
	}else{
		_state = 0;
	}
}

@end
