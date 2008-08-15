//
//  OHTitleBarButtonCell.h
//  OpenHUD
//
//  Created by Andy Matuschak on 1/2/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// I'm not entirely sure what _isObscured does or what needs it, but AppKit
// throws exceptions left and right if a title bar widget doesn't respond
// to accessors on this variable. Annoying. And not documented.

@interface OHTitleBarButtonCell : NSButtonCell {
	BOOL _isObscured;
}

@end
