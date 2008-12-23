//
//  GInspectWindow.h
//  Inspecteur
//
//  Created by Raphael Bost on 11/02/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define GInspectViewClosedNotification @"Inspect View Closed"

const float _barHeight;
@interface GInspectWindow : NSPanel {
	IBOutlet NSButton *_disclosureButton;
	IBOutlet NSImageView *_bckgrd;
	
	NSSize _previousFrameSize;
	
	float _widthWhenClosed;
	
	NSMutableArray *_views;
	
	BOOL _isCollapsed;
	
	unsigned int _indexOfChange;
	
	@private
		BOOL __acceptNotif;
}
- (void)setMinFrameAnimate:(BOOL)flag;
- (IBAction)togglePanel:(id)sender;
- (float)widthWhenClosed;
- (void)setWidthWhenClosed:(float)w;
- (void)updateViewList;
- (void)addView:(NSView *)view title:(NSString *)title collapsed:(BOOL)flag;
- (void)removeView:(NSView *)view;
- (BOOL)isCollapsed;
- (void)setCollapsed:(BOOL)flag; 
- (void)collapseAllViews;

- (void)updateWindowPosition;
- (void)saveULCorner;
@end

@interface NSWindow (Extensions)
- (NSPoint)upperLeftCorner;
- (void)setUpperLeftCorner:(NSPoint)point;
@end
