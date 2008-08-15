//
//  OHTitleBarButtonCell.m
//  OpenHUD
//
//  Created by Andy Matuschak on 1/2/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "OHTitleBarButtonCell.h"

// See the header for notes on what this is all about.

@implementation OHTitleBarButtonCell

- (void)setObscured:(BOOL)isObscured
{
	_isObscured = isObscured;
}

- (BOOL)isObscured
{
	return _isObscured;
}

@end
