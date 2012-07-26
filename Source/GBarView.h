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
	NSString *_identifier;
	NSView *_associatedView;
	BOOL _isCollapsed;
	
	NSButton *_disclosureButton;  
	
    CGFloat _defaultWidth;

#ifdef SHOW_CLOSE_BUTTON   	
	NSButton *_closeButton;    
#endif
}

- (NSString *)title;
- (void)setTitle:(NSString *)s;

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)s;

- (BOOL)isCollapsed;
- (void)setCollapsed:(BOOL)flag;

- (NSView *)associatedView;
- (void)setAssociatedView:(NSView *)view;

- (float)minWidth;
- (CGFloat)defaultWidth;

- (NSString *)autosaveString;
- (void)upateCollapse;
@end
