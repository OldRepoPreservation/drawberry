//
//  GInspectWindow.m
//  Inspecteur
//
//  Created by Raphael Bost on 11/02/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import "GInspectWindow.h"

#import "GBarView.h"

#define GCollapsedHeight 26
#define GBaseHeight 0
#define GHeightOffset 0

//const float _barHeight = 30;
const float _barHeight = 18;

@implementation GInspectWindow
- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)styleMask 
				  backing:(NSBackingStoreType)backingType 
					defer:(BOOL)flag 
{
	self = [super initWithContentRect:contentRect styleMask:(styleMask) backing:backingType defer:flag];
	if (self != nil) {
		
		_previousFrameSize = [self frame].size;
		_widthWhenClosed = 150;
		
		_views = [[NSMutableArray alloc] init];
		_isCollapsed = NO;
		__acceptNotif = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(windowWillMove:) 
													 name:NSWindowWillMoveNotification 
												   object:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(windowDidMove:) 
													 name:NSWindowDidMoveNotification 
												   object:self];
		//		[[[[[[self contentView] superview] subviews] objectAtIndex:2] retain] removeFromSuperviewWithoutNeedingDisplay];
//		[[[[[[self contentView] superview] subviews] objectAtIndex:1] retain] removeFromSuperviewWithoutNeedingDisplay];
	}
	return self;
}

- (void) dealloc {
	[_views release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)awakeFromNib
{	
	[[[self contentView] superview] addSubview:_disclosureButton];
	
	NSRect cbFrame = [[[[[self contentView] superview] subviews] objectAtIndex:0] frame];

	NSPoint origin;
	origin.x = [self frame].size.width - 20;
	origin.y = (int)(cbFrame.origin.y - (cbFrame.size.height / 2) + ([_disclosureButton frame].size.height /2))-4;

	[_disclosureButton setFrameOrigin:origin];
//	[_bckgrd setFrame:NSMakeRect(0,7,[self frame].size.width,MIN([self frame].size.height-30,0))];
}


- (void)setMinFrameAnimate:(BOOL)flag
{
	NSRect newFrame;
	
	_previousFrameSize = [self frame].size;
	
	newFrame.origin = [self frame].origin;
	newFrame.origin.y += [self frame].size.height - 16;
	
	newFrame.size = NSMakeSize(_widthWhenClosed,16);
	
	[self setFrame:newFrame display:YES animate:flag];
	
}

- (IBAction)togglePanel:(id)sender
{
	[self setCollapsed:((BOOL)[sender state])];
}

- (float)widthWhenClosed { return _widthWhenClosed;}
- (void)setWidthWhenClosed:(float)w 
{
	_widthWhenClosed = w;
	
	if([_disclosureButton state] != NSOffState){
		NSRect f = [self frame];
		f.size.width = _widthWhenClosed;
		
		[self setFrame:f display:YES animate:YES];
	}
}

- (BOOL)isCollapsed { return _isCollapsed;}
- (void)setCollapsed:(BOOL)flag
{
	if([self frameAutosaveName]){
		NSString *collapseKey;
		collapseKey = [NSString stringWithFormat:@"%@ Collapsed",[self frameAutosaveName]];
		[[NSUserDefaults standardUserDefaults] setBool:flag forKey:collapseKey];
	}
	
	if (flag == _isCollapsed) {
		return;
	}
	_isCollapsed = flag;
	
	
	[_disclosureButton setState:(int)( _isCollapsed)];
	
	NSRect newFrame;
	if (! _isCollapsed) {
		newFrame.size = _previousFrameSize;
		newFrame.origin = [self frame].origin;
		newFrame.origin.y -= (_previousFrameSize.height - GCollapsedHeight);

		NSEnumerator *e;
		e = [[[self contentView] subviews] objectEnumerator];
		NSView *v;
		NSRect frame;
		while((v = [e nextObject])){
			frame = [v frame];
			frame.origin.y -= 5.0;
			[v	setFrame:frame];
//			[v setAutoresizingMask:NSViewMinYMargin];
		}
	}else {
		_previousFrameSize = [self frame].size;
		
		newFrame.origin = [self frame].origin;
		newFrame.origin.y += [self frame].size.height - GCollapsedHeight;
		
		newFrame.size = NSMakeSize(_widthWhenClosed, GCollapsedHeight);
		
		NSEnumerator *e;
		
		e = [[[self contentView] subviews] objectEnumerator];
		NSView *v;
		NSRect frame;
		while((v = [e nextObject])){
			frame = [v frame];
			frame.origin.y += 5.0;
			[v	setFrame:frame];
			[v setAutoresizingMask:NSViewMaxYMargin];
		}
	}
	[self setFrame:newFrame display:YES animate:YES];
	
}

- (float)computeWidth
{
	float maxWidth = _widthWhenClosed;
    
	NSEnumerator *e = [_views objectEnumerator];
	NSView *view;
	GBarView *barView;
	
	// calculate maxWidth
	while ((barView = [e nextObject])) {
		if (![barView isCollapsed]) {
			view = [barView associatedView];
			maxWidth = MAX(maxWidth, [barView defaultWidth]);
		}
		maxWidth = MAX(maxWidth, [barView minWidth]);
	}
	
    return maxWidth;
}

- (void)updateViewList
{
	float titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
	titleBarHeight = 20;
	float accumulatedHeight = GBaseHeight;
	
	float oldHeight = [self frame].size.height;
	float maxWidth = [self computeWidth];

	NSMutableArray *viewsToRemove = [[NSMutableArray alloc] init];
	
	NSEnumerator *enumerator = [[[self contentView] subviews] objectEnumerator];
	NSView *view;

	while((view = [enumerator nextObject])){
		if([view tag] != 1000){
			[viewsToRemove addObject:view];
		}
	}
	
	[viewsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSEnumerator *e;
	GBarView *barView;
	NSRect vFrame;
	
	e = [_views reverseObjectEnumerator];
	
	while ((barView = [e nextObject])) {
		if (![barView isCollapsed]) {
			view = [barView associatedView];
			
			vFrame.origin.x = 0;
			vFrame.origin.y = accumulatedHeight;
			vFrame.size = [view frame].size;
			
			[view setFrame:vFrame];
			
			[[self contentView] addSubview:view];
			
			accumulatedHeight += vFrame.size.height;
		}
		vFrame = NSMakeRect(0,accumulatedHeight,maxWidth,_barHeight+1);
		
		[barView setFrame:vFrame];
		[[self contentView] addSubview:barView];
		
		accumulatedHeight += _barHeight;
	}
	
	NSRect frame;
	frame = [self frame];
	frame.size.height = accumulatedHeight+titleBarHeight+GHeightOffset;
	frame.size.width = maxWidth;
	frame.origin.y -= (accumulatedHeight+titleBarHeight - oldHeight);

    [viewsToRemove release];
    
	[self setFrame:frame display:YES animate:YES];
}

- (void)updateWindowFrame
{
	float titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
	titleBarHeight = 20;
	float accumulatedHeight = GBaseHeight;
	
	float oldHeight = [self frame].size.height;
	float maxWidth = [self computeWidth];
	
	NSEnumerator *e;
	NSView *view;
	GBarView *barView;
	NSRect vFrame;
		
	e = [_views reverseObjectEnumerator];
	
	while ((barView = [e nextObject])) {
		if (![barView isCollapsed]) {
			view = [barView associatedView];
			
			vFrame.origin.x = 0;
			vFrame.origin.y = accumulatedHeight;
			vFrame.size = [view frame].size;
			
			accumulatedHeight += vFrame.size.height;
		}
		vFrame = NSMakeRect(0,accumulatedHeight,maxWidth,_barHeight+1);
		
		accumulatedHeight += _barHeight ;
        [barView setAutoresizingMask:NSViewMinYMargin];
    }
	             
	//[_bckgrd setFrameOrigin:NSMakePoint(0,20)];
	
	NSRect frame;
	frame = [self frame];
	frame.size.height = accumulatedHeight+titleBarHeight+GHeightOffset;
	frame.size.width = maxWidth;
	frame.origin.y -= (accumulatedHeight+titleBarHeight - oldHeight);
	[self setFrame:frame display:YES animate:YES];
	
	
}

- (void)addView:(NSView *)addedView title:(NSString *)title collapsed:(BOOL)flag
{
	
	GBarView *addedBarView = [[GBarView alloc] initWithFrame:NSMakeRect(0,0,[self frame].size.width,_barHeight)];
	[addedBarView setAssociatedView:addedView];
    [addedView setAutoresizesSubviews:YES];
	[addedBarView setTitle:NSLocalizedString(title,nil)];
	[addedBarView setIdentifier:title];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(collapseDidChange:) 
												 name:GBarStateDidChangeNotification 
											   object:addedBarView];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(barClose:) 
												 name:GBarDidCloseNotification 
											   object:addedBarView];
	
	[_views addObject:addedBarView];
	
	[[self contentView] addSubview:addedBarView];

	[addedBarView upateCollapse];
	
	if(![addedBarView isCollapsed]){
		[[self contentView] addSubview:[addedBarView associatedView]];
	}
	
	float titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
	titleBarHeight = 20;
	float accumulatedHeight = GBaseHeight;
	
	float oldHeight = [self frame].size.height;
	float maxWidth = [self computeWidth];
	
	NSEnumerator *e;
	NSView *view;
	GBarView *barView;
	NSRect vFrame;
	
	e = [_views reverseObjectEnumerator];
	
	while ((barView = [e nextObject])) {
		if (![barView isCollapsed]) {
			view = [barView associatedView];
			
			vFrame.origin.x = 0;
			vFrame.origin.y = accumulatedHeight;
			vFrame.size = [view frame].size;
			
			accumulatedHeight += vFrame.size.height;
			[view setAutoresizingMask:(NSViewMinYMargin|NSViewWidthSizable)];
		}
		vFrame = NSMakeRect(0,accumulatedHeight,maxWidth,_barHeight+1);
		[barView setFrameSize:vFrame.size];
		
		accumulatedHeight += _barHeight;
		
		[barView setAutoresizingMask:NSViewMinYMargin];
	}
	
	NSRect frame;
	frame = [self frame];
	frame.size.height = accumulatedHeight+titleBarHeight+GHeightOffset;
	frame.size.width = maxWidth;
	frame.origin.y -= (accumulatedHeight+titleBarHeight - oldHeight);
	
	[self setFrame:frame display:YES animate:YES];
	
//	[[self contentView] addSubview:[addedBarView associatedView]];
//	[[self contentView] addSubview:addedBarView];
	
	
	[addedBarView setFrameOrigin:NSMakePoint(0,[[addedBarView associatedView] frame].size.height)];
	[[addedBarView associatedView] setFrameOrigin:NSZeroPoint];
	
//	[addedBarView setCollapsed:flag];
	 //[_bckgrd setFrameOrigin:NSMakePoint(0,20)];
	
    [addedBarView release];
}

- (void)removeView:(NSView *)removedView
{
	if([removedView tag] == 1000){ 
		return;
	}
	
	NSEnumerator *e = [_views objectEnumerator];
	GBarView *removedBarView;
	int indexOfRemovedView = 0;
	
	while ((removedBarView = [e nextObject])) {
		if ([[removedBarView associatedView] isEqual:removedView]) {
			break;
		}
		indexOfRemovedView++;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GBarStateDidChangeNotification object:removedBarView];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GBarDidCloseNotification object:removedBarView];
	
	[_views removeObject:removedBarView];
	[removedView removeFromSuperview];
	
	// calculate new frame
	float titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
	titleBarHeight = 20;
	float accumulatedHeight = GBaseHeight;
	
	float oldHeight = [self frame].size.height;
	float maxWidth = [self computeWidth];
	
	NSView *view;
	GBarView *barView;
	NSRect vFrame;
	int i = 0;
	
	e = [_views objectEnumerator];
	
	while ((barView = [e nextObject])) {
		if (![barView isCollapsed]) {
			view = [barView associatedView];
			
			vFrame.origin.x = 0;
			vFrame.origin.y = accumulatedHeight;
			vFrame.size = [view frame].size;
			
			accumulatedHeight += vFrame.size.height;
			
			if (i < indexOfRemovedView) {
                [view setAutoresizingMask:(NSViewMinYMargin|NSViewWidthSizable)];
			}else{
                [view setAutoresizingMask:(NSViewMaxYMargin|NSViewWidthSizable)];
			}
		}
		vFrame = NSMakeRect(0,accumulatedHeight,maxWidth,_barHeight+1);
		[barView setFrameSize:vFrame.size];
		
		accumulatedHeight += _barHeight;
		
		if (i < indexOfRemovedView) {
			[barView setAutoresizingMask:NSViewMinYMargin];
		}else{
			[barView setAutoresizingMask:NSViewMaxYMargin];
		}
		
		
		i++;
	}
	
	NSRect frame;
	frame = [self frame];
	frame.size.height = accumulatedHeight+titleBarHeight+GHeightOffset;
	frame.size.width = maxWidth;
	frame.origin.y -= (accumulatedHeight+titleBarHeight - oldHeight);
	
	[self setFrame:frame display:YES animate:YES];
	
	[removedBarView removeFromSuperview];	
	//[_bckgrd setFrameOrigin:NSMakePoint(0,20)];
	
}

- (void)collapseDidChange:(NSNotification *)n
{
	if([[n object] isCollapsed]){
		NSView *removedView = [[n object] associatedView];
		int indexOfRemovedView = [_views indexOfObject:[n object]];
		
		float titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
		titleBarHeight = 20;
		float accumulatedHeight = GBaseHeight;
		
		float oldHeight = [self frame].size.height;
		float maxWidth = [self computeWidth];
		
		NSEnumerator * e;
		NSView *view;
		GBarView *barView;
		NSRect vFrame;
		int i = 0;
		
		[removedView removeFromSuperview];
		e = [_views objectEnumerator];
		
		while ((barView = [e nextObject])) {
			if (![barView isCollapsed]) {
				view = [barView associatedView];
				
				vFrame.origin.x = 0;
				vFrame.origin.y = accumulatedHeight;
				vFrame.size = [view frame].size;
				
				accumulatedHeight += vFrame.size.height;
				
				if (i < indexOfRemovedView) {
                    [view setAutoresizingMask:(NSViewMinYMargin|NSViewWidthSizable)];
				}else{
                    [view setAutoresizingMask:(NSViewMaxYMargin|NSViewWidthSizable)];
				}
			}
			vFrame = NSMakeRect(0,accumulatedHeight,maxWidth,_barHeight+1);
			[barView setFrameSize:vFrame.size];
			//[barView setFrame:vFrame];
			accumulatedHeight += _barHeight;
			
			if (i <= indexOfRemovedView) {
				[barView setAutoresizingMask:NSViewMinYMargin];
			}else{
				[barView setAutoresizingMask:NSViewMaxYMargin];
			}
			
			
			i++;
		}
		
		NSRect frame;
		frame = [self frame];
		frame.size.height = accumulatedHeight+titleBarHeight+GHeightOffset;
		frame.size.width = maxWidth;
		frame.origin.y -= (accumulatedHeight+titleBarHeight - oldHeight);
		
		[self setFrame:frame display:YES animate:__acceptNotif];
		
		
	}else {
		
		NSView *removedView = [[n object] associatedView];
		int indexOfRemovedView = [_views indexOfObject:[n object]];
		
		float titleBarHeight = [self frame].size.height - [[self contentView] frame].size.height;
		titleBarHeight = 20;
		float accumulatedHeight = GBaseHeight;
		float viewNewOrigin = 0;
		
		float oldHeight = [self frame].size.height;
		float maxWidth = [self computeWidth];
		
		NSEnumerator * e;
		NSView *view;
		GBarView *barView;
		NSRect vFrame;
		int i = 0;
				
		e = [_views objectEnumerator];
		
		while ((barView = [e nextObject])) {
			
			if (![barView isCollapsed]) {
				view = [barView associatedView];
				
				vFrame.origin.x = 0;
				vFrame.origin.y = accumulatedHeight;
				vFrame.size = [view frame].size;
				
				accumulatedHeight += vFrame.size.height;
				
				if (i < indexOfRemovedView) {
                    [view setAutoresizingMask:(NSViewMinYMargin|NSViewWidthSizable)];
				}else{
                    [view setAutoresizingMask:(NSViewMaxYMargin|NSViewWidthSizable)];
				}
			}
			vFrame = NSMakeRect(0,accumulatedHeight,maxWidth,_barHeight+1);
			[barView setFrameSize:vFrame.size];
			
			accumulatedHeight += _barHeight;
			
			if (i <= indexOfRemovedView) {
				[barView setAutoresizingMask:NSViewMinYMargin];
			}else{
				[barView setAutoresizingMask:NSViewMaxYMargin];
			}
			
			i++;
		}
		
		
		// now recalculate the addedView new coordinates
		
		for (i=[_views count]-1; i>indexOfRemovedView; i--) {
			barView = [_views objectAtIndex:i];
			
			viewNewOrigin += [barView frame].size.height +1.0;
			
			if (![barView isCollapsed]) {
				viewNewOrigin += [[barView associatedView] frame].size.height;
			}
		}
		
		NSRect frame;
		frame = [self frame];
		frame.size.height = accumulatedHeight+titleBarHeight+GHeightOffset;
		frame.size.width = maxWidth;
		frame.origin.y -= (accumulatedHeight+titleBarHeight - oldHeight);
		
		[self setFrame:frame display:YES animate:__acceptNotif];

		[removedView setFrameOrigin:NSMakePoint(0,viewNewOrigin)];
		[[self contentView] addSubview:removedView];
		
	}
	
	//[_bckgrd setFrameOrigin:NSMakePoint(0,20)];
	
}

- (void)barClose:(NSNotification *)n
{
	NSView *v = [n object];
	
	if([_views containsObject:v]){
		NSNotification *note = [NSNotification notificationWithName:GInspectViewClosedNotification object:self userInfo:[NSDictionary dictionaryWithObject:[(GBarView *)v associatedView] forKey:@"Closed View"]];
		[[NSNotificationCenter defaultCenter] postNotification:note];
		[self removeView:[(GBarView *)v associatedView]];
	}
}

- (void)windowWillMove:(NSNotification *)notif
{
    NSEvent *ev;
	
	ev=[NSApp nextEventMatchingMask:NSLeftMouseDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.2] inMode:NSEventTrackingRunLoopMode dequeue:YES];	
	
	if (!NSPointInRect([ev locationInWindow], NSMakeRect(0, 0, [self frame].size.width, GCollapsedHeight))) {
		return;
	}
	
	ev=[NSApp nextEventMatchingMask:NSLeftMouseDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.2] inMode:NSEventTrackingRunLoopMode dequeue:YES];	
	
	if (ev && ([ev clickCount] == 2) ) {
		[self setCollapsed:![self isCollapsed]];
	}
}

- (void)collapseAllViews
{
	__acceptNotif = NO;
	
	NSEnumerator *e = [_views objectEnumerator];
	GBarView *barView;

	while((barView = [e nextObject])){
		[barView setCollapsed:YES];
	}
	__acceptNotif = YES;     
//	[self updateViewList];
	[self updateWindowFrame];
}
    
- (BOOL)setFrameAutosaveName:(NSString *)frameName
{
	BOOL flag;
	NSString *collapseKey;
	collapseKey = [NSString stringWithFormat:@"%@ Collapsed",frameName];
	
	flag = [[NSUserDefaults standardUserDefaults] boolForKey:collapseKey];
	
	[self setCollapsed:flag];
	[_disclosureButton setState:flag];
	
	return [super setFrameAutosaveName:frameName];
}

- (void)updateWindowPosition
{
	NSString *pointString;
	
	pointString = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@ UL corner",[self frameAutosaveName]]];
	
	if(pointString){
		NSPoint point = NSPointFromString(pointString);
		[self setUpperLeftCorner:point];		
	}else{

	}
}
- (void)saveULCorner
{
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromPoint([self upperLeftCorner]) forKey:[NSString stringWithFormat:@"%@ UL corner",[self frameAutosaveName]]];
}

- (void)close
{
	[self saveULCorner];
	[super close];
}

- (void)windowDidMove:(NSNotification *)note
{
	[self saveULCorner];
}
@end

@implementation NSWindow (Extensions)
- (NSPoint)upperLeftCorner
{
	NSRect frame;
	
	frame = [self frame];
	return NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height);
}

- (void)setUpperLeftCorner:(NSPoint)point
{
	[self setFrameOrigin:NSMakePoint(point.x, point.y - [self frame].size.height)];
}

@end