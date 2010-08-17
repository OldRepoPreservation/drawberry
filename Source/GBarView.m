//
//  GBarView.m
//  Inspecteur
//
//  Created by Raphael Bost on 11/02/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import "GBarView.h"
//#import <GradientPanel/GradientPanel.h>

#define GBarDisclosureButtonX 10.0f
#define GBarCloseButtonMargin 15.0f
#define GBarTitleX 25.0f 

@interface GBarView (Private)
- (IBAction)_collapseButtonAction:(id)sender;
- (IBAction)_closeButtonAction:(id)sender;
@end

@implementation GBarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_title = @"";
		NSImage *image;
		
		_disclosureButton = [[NSButton alloc] initWithFrame:NSMakeRect(GBarDisclosureButtonX,frame.size.height/2 - 6,13,13)];
		[_disclosureButton setTitle:nil];
		[_disclosureButton setButtonType:NSToggleButton];
		[_disclosureButton setBezelStyle:NSRegularSquareBezelStyle];
		[_disclosureButton setBordered:NO];
		[_disclosureButton setImagePosition:NSImageOnly]; 
		
		[self addSubview:_disclosureButton];
		[_disclosureButton release];
		
		image = [NSImage imageNamed:@"disclosureArrow_right"];
		[_disclosureButton setImage:image];
		
		image = [NSImage imageNamed:@"disclosureArrow_down"];
		[_disclosureButton setAlternateImage:image];

		_isCollapsed = NO;
		
		[_disclosureButton setState:NSOnState];
		[_disclosureButton setTarget:self];
		[_disclosureButton setAction:@selector(_collapseButtonAction:)];
 
#ifdef SHOW_CLOSE_BUTTON   	
		_closeButton = [[NSButton alloc] initWithFrame:
							NSMakeRect( frame.size.width - GBarCloseButtonMargin,2,12,12)];
		NSSize closeImageSize = [_closeButton frame].size;
		
		[_closeButton setTitle:nil];
		[_closeButton setButtonType:NSMomentaryChangeButton];
		[_closeButton setBezelStyle:NSRegularSquareBezelStyle];
		[_closeButton setBordered:NO];
		[_closeButton setImagePosition:NSImageOnly]; 
		
		image = [NSImage imageNamed:@"cancel"];
		[image setScalesWhenResized:YES];
		[image setSize:closeImageSize];
		[_closeButton setImage:image];
		
		image = [NSImage imageNamed:@"cancel_pressed"];
		[image setScalesWhenResized:YES];
		[image setSize:closeImageSize];
		[_closeButton setAlternateImage:image];
		
		[_closeButton setAutoresizingMask:(NSViewMinXMargin)];
	    [self addSubview:_closeButton];
		[_closeButton release];
		
		[_closeButton setTarget:self];
		[_closeButton setAction:@selector(_closeButtonAction:)];
 #endif                        
	//	[self setAutoresizingMask:(NSViewMaxYMargin | NSViewMinYMargin | NSViewWidthSizable )];
    }
    return self;
}

- (void) dealloc {
	[_title release];
	[_associatedView release];
	[super dealloc];
}
 

- (void)drawRect:(NSRect)rect{
//	[[NSColor redColor] set];
//	[NSBezierPath fillRect:rect];
	NSGradient *gradient;
	gradient = [[NSGradient alloc] initWithStartingColor:[NSColor clearColor] endingColor:[[NSColor whiteColor] colorWithAlphaComponent:0.1]];
	[gradient drawInRect:rect angle:90.0];
	[gradient release];
	
	NSAttributedString *s = [[NSAttributedString alloc] initWithString:_title attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],NSForegroundColorAttributeName,nil]];
	[s drawAtPoint:NSMakePoint(GBarTitleX,[self frame].size.height/2-[s size].height/2)];
	[s release];
	
   	NSBezierPath *path = [NSBezierPath bezierPath];
//	[path moveToPoint:NSMakePoint(0,0.5)];
//	[path lineToPoint:NSMakePoint([self frame].size.width,0.5)];
	
//	[path moveToPoint:NSMakePoint(0,[self frame].size.height-0.5)];
//	[path lineToPoint:NSMakePoint([self frame].size.width,[self frame].size.height-0.5)];
	[[NSColor grayColor] set];
//	[path stroke];
	
//	if(!_isCollapsed){
		path = [NSBezierPath bezierPath];
		[path moveToPoint:NSMakePoint(0.0,[self frame].size.height-0.5)];
		[path lineToPoint:NSMakePoint([self frame].size.width,[self frame].size.height-0.5)];
		[path stroke];
//	}
	
	if(!_isCollapsed){
		path = [NSBezierPath bezierPath];
		
		[path moveToPoint:NSMakePoint(0.0,0.0)];
		[path lineToPoint:NSMakePoint([self frame].size.width,0.0)];
		[[NSColor whiteColor] set];
		[path stroke];

	}
	
}
- (void)mouseDown:(NSEvent *)e
{
	[self setCollapsed:!_isCollapsed];
}

- (void)mouseDragged:(NSEvent *)e
{
	NSPoint origin = [[self window] frame].origin;
	
	origin.x += [e deltaX];
	origin.y -= [e deltaY];
	
	[[self window] setFrameOrigin:origin];
}

- (NSString *)title {return _title;}
- (void)setTitle:(NSString *)s
{
	[_title release];
	_title = [s retain];
	
	[self setNeedsDisplay:YES];
		
}

- (NSString *)identifier
{
	return _identifier;
}
- (void)setIdentifier:(NSString *)s
{
	[_identifier release];
	_identifier = [s retain];	
}

- (void)upateCollapse
{
	BOOL flag;
	NSString *collapseKey;
	
	if([self autosaveString]){
		collapseKey = [NSString stringWithFormat:@"%@ Collapsed",[self autosaveString]];
		
		flag = [[NSUserDefaults standardUserDefaults] boolForKey:collapseKey];
		
		[self setCollapsed:flag];
		[_disclosureButton setState:!flag];		
	}else{
		NSLog(@"bad autosave name");
	}
	
}
- (NSView *)associatedView
{
	return _associatedView;
}

- (void)setAssociatedView:(NSView *)view
{
	[_associatedView release];
	_associatedView = [view retain];
}

- (BOOL)isCollapsed { return _isCollapsed;}
- (void)setCollapsed:(BOOL)flag
{
	if([self autosaveString]){
		NSString *collapseKey;
		collapseKey = [NSString stringWithFormat:@"%@ Collapsed",[self autosaveString]];
		[[NSUserDefaults standardUserDefaults] setBool:flag forKey:collapseKey];
	}
	
	_isCollapsed = flag;
	[_disclosureButton setState:(int)(! _isCollapsed)];
	
	NSNotification *note = [NSNotification notificationWithName:GBarStateDidChangeNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotification:note];
		
}

- (IBAction)_collapseButtonAction:(id)sender
{
//	_isCollapsed = !((BOOL)[_disclosureButton state]);

//	NSNotification *note = [NSNotification notificationWithName:GBarStateDidChangeNotification object:self];
//	[[NSNotificationCenter defaultCenter] postNotification:note];
	
	[self setCollapsed:!((BOOL)[_disclosureButton state])];
}

- (IBAction)_closeButtonAction:(id)sender
{
	NSNotification *note = [NSNotification notificationWithName:GBarDidCloseNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotification:note];

}

- (float)minWidth
{
	float width = GBarTitleX + GBarCloseButtonMargin + 14 + [_title sizeWithAttributes:nil].width;
	
	return width;
}

- (NSString *)description
{
	return  [NSString stringWithFormat:@"%@ : %@, %@", [super description], _title, [_associatedView description]];
}

- (NSString *)autosaveString
{
	if([[self window] frameAutosaveName])
		return [NSString stringWithFormat:@"%@ %@",[[self window] frameAutosaveName], [self identifier]];
	
	return nil;
}
@end
