//
//  OHWindow.h
//  OpenHUD
//
//  Created by Andy Matuschak on 1/1/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OHConstants.h"

extern const int OHHUDWindowMask;

// The HUDStyle determines whether a given window looks like an iApp HUD or a pro app HUD.

@interface OHWindow : NSPanel {
	OHStyle HUDStyle;
}

- (OHStyle)HUDStyle;
- (void)setHUDStyle:(OHStyle)style;

@end
