//
//  GBarView.h
//  Inspecteur
//
//  Created by Raphael Bost on 11/02/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define GBarStateDidChangeNotification @"Bar State Did Change"
#define GBarDidCloseNotification @"Bar Did Close"

//#define SHOW_CLOSE_BUTTON

@interface GBarView : NSView {
	NSString *_title;
	NSView *_associatedView;
	BOOL _isCollapsed;
	
	NSButton *_disclosureButton;  
	
#ifdef SHOW_CLOSE_BUTTON   	
	NSButton *_closeButton;    
#endif
}

- (NSString *)title;
- (void)setTitle:(NSString *)s;

- (BOOL)isCollapsed;
- (void)setCollapsed:(BOOL)flag;

- (NSView *)associatedView;
- (void)setAssociatedView:(NSView *)view;

- (float)minWidth;

- (NSString *)autosaveString;
- (void)upateCollapse;
@end
