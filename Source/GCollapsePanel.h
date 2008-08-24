//
//  GCollapsePanel.h
//  Geodes
//
//  Created by Raphael Bost on 17/03/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GCollapsePanel : NSPanel {
	IBOutlet NSButton *_disclosureButton;
	
	NSSize _previousFrameSize;
	
	float _widthWhenClosed;
	
	NSMutableArray *_views;
	
	BOOL _isCollapsed;
}

- (IBAction)togglePanel:(id)sender;
- (float)widthWhenClosed;
- (void)setWidthWhenClosed:(float)w;
- (BOOL)isCollapsed;
- (void)setCollapsed:(BOOL)flag;

@end
