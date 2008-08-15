//
//  OHConstants.h
//  OpenHUD
//
//  Created by Andy Matuschak on 1/1/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OHWindow;

//#define HUDStyle() [(OHWindow *)[(([self isKindOfClass:[NSCell class]]) ? [(NSCell *)self controlView] : (NSView *)self) window] HUDStyle]
//#define HUDStyle() 0

typedef enum
{
	OHIAppStyle,
	OHProStyle
} OHStyle;

extern NSString * OHWindowHUDStyleChangedNotificationName;