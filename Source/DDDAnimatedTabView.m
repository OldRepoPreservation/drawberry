//
//  DDDAnimatedTabView.m
//  DockDockDock
//
//  Created by Raphael Bost on 04/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDDAnimatedTabView.h"


@implementation DDDAnimatedTabView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[[NSColor whiteColor] set];
//	[[NSBezierPath bezierPathWithRect:rect] fill];
//	NSRectFill(rect);
	[[NSColor clearColor] set];
//	[[NSBezierPath bezierPathWithRect:rect] fill];
//	NSRectFill(rect);
	[super drawRect:rect];
}

- (void)awakeFromNib
{
	_transitionDuration = 1.0;
	_transitionStyle = CGFlip;
}
- (float)transitionDuration
{
	return _transitionDuration;
}

- (void)setTransitionDuration:(float)newTransitionDuration
{
	_transitionDuration = newTransitionDuration;
}


- (DDDAnimatedTabViewTransitionStyle)transitionStyle {
    return _transitionStyle;
}

- (void)setTransitionStyle:(DDDAnimatedTabViewTransitionStyle)newTransitionStyle {
	_transitionStyle = newTransitionStyle;
}

- (IBAction)selectMatrix:(id)sender
{
	[self selectTabViewItemWithIdentifier:@"Matrix"];
}
- (IBAction)selectEditor:(id)sender
{
	[self selectTabViewItemWithIdentifier:@"Editor"];
}

- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem {
	if(_transitionStyle == 0){ // no transition style
		[super selectTabViewItem:tabViewItem];

	} else if(_transitionStyle < 10){ 	// Otherwise is the transition for CoreGraphics

		int lastTab = [self numberOfTabViewItems]-1;		
		// fromTab set before changing the tab, as we need to know where we're coming from
		int fromTab = [self indexOfTabViewItem:[self selectedTabViewItem]];
		// Change the tab. wont be rendered yet.
		[super selectTabViewItem:tabViewItem];
		// now we can set toTab.
		int toTab = [self indexOfTabViewItem:[self selectedTabViewItem]];

		int option; // for direction
		
		// following logic for making different directions
		// The directions follow a cube style pattern
		// and make it look more realistic.
		if(toTab > fromTab){ // moving up
//			if(toTab == lastTab || fromTab == 0){ //to last tab or from first tab
//				option = CGSUp;
//			} else {
				option = CGSLeft;
//			}
		} else if(toTab < fromTab){ // moving back
//			if(toTab == 0 || fromTab == lastTab){ // to first tab or from last tab
//				option = CGSDown;
//			} else {
				option = CGSRight;
//			}
		}
		// Runs the CoreGraphics animation
		[self turnWithTransition:_transitionStyle option:option duration:_transitionDuration];
		// if we were slowmo, we don't want it on by default next time.		
	}
}

#pragma mark -
#pragma mark *** Core Graphics ***

// CoreGraphics transition
- (void)turnWithTransition:(CGSTransitionType)transition option:(CGSTransitionOption)option duration:(float)duration
{
// declare our variables  
int handle;
CGSTransitionSpec spec;

// assign our transition handle
handle = -1;

// specify our specifications
spec.unknown1=0;
spec.type= transition; // cube, swap, etc.
spec.option=option | (1<<7); // "(1<<7)" is the transparent mask
spec.backColour=NULL; // doesn't matter anyway since we're transparent
spec.wid=[[self window] windowNumber]; // windowNumber. 0 for whole desktop ;)

// LetÕs get a connection
CGSConnection cgs= _CGSDefaultConnection();

// Create a transition
CGSNewTransition(cgs, &spec, &handle);

// Redraw the window
// !important otherwise you get the tab changing only after the transition.
[[self window] display];

/* Pass the connection, handle,
* and duration to apply the animation
*/
CGSInvokeTransition(cgs, handle, duration);
/* We need to wait for the transition to finish
* before we get rid of it, otherwise weÕll get
* all sorts of nasty errors... or maybe not.
*/
usleep((useconds_t)(duration*1000000));


/* Finally, release all our variables */
CGSReleaseTransition(cgs, handle);
handle=0;
}

@end
