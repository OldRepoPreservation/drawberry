//
//  GCollapsePanel.m
//  Geodes
//
//  Created by Raphael Bost on 17/03/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import "GCollapsePanel.h"

@implementation GCollapsePanel

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)styleMask 
				  backing:(NSBackingStoreType)backingType 
					defer:(BOOL)flag {
	self = [super initWithContentRect:contentRect styleMask:styleMask backing:backingType defer:flag];
	if (self != nil) {

		_previousFrameSize = [self frame].size;
		_widthWhenClosed = 150;
		
		_views = [[NSMutableArray alloc] init];
		_isCollapsed = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(windowWillMove:) 
													 name:NSWindowWillMoveNotification 
												   object:self];
 	   
       
	   if(styleMask & NSClosableWindowMask)
	   {
//	   	   [[[[[[self contentView] superview] subviews] objectAtIndex:2] retain] removeFromSuperviewWithoutNeedingDisplay];
//		   [[[[[[self contentView] superview] subviews] objectAtIndex:1] retain] removeFromSuperviewWithoutNeedingDisplay];
	   }
	//[self setAlphaValue:0];
		   
//	[self setupAppearance];
				
   }
	return self;
}

- (void)setupAppearance
{   
	[self setBackgroundColor: [NSColor clearColor]];
    [self setLevel: NSFloatingWindowLevel];
    [self setAlphaValue:1.0];
	[self setOpaque:NO];
	[self setHasShadow:YES];
	
	// [self setOpaque:YES];
	// [self setMovableByWindowBackground:YES];  
	// [self setAlphaValue:1.0];         
	// [self setBackgroundColor:[NSColor clearColor]];
	// [self setLevel:NSFloatingWindowLevel];
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
		newFrame.origin.y -= (_previousFrameSize.height - 27);
	}else {                                               
		_previousFrameSize = [self frame].size;
		
		newFrame.origin = [self frame].origin;
		newFrame.origin.y += [self frame].size.height - 27;
		
		newFrame.size = NSMakeSize(_widthWhenClosed,27) ;
		
	}
	[self setFrame:newFrame display:YES animate:YES];
	
}

- (void)windowWillMove:(NSNotification *)notif
{
    NSEvent *ev;
	
	ev=[NSApp nextEventMatchingMask:NSLeftMouseDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.2] inMode:NSEventTrackingRunLoopMode dequeue:YES];	
	ev=[NSApp nextEventMatchingMask:NSLeftMouseDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.2] inMode:NSEventTrackingRunLoopMode dequeue:YES];	
	
		if (ev && ([ev clickCount] == 2) ) {
					[self setCollapsed:![self isCollapsed]];
		}
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
@end
