//
//  DBDrawingExtensions.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void DBDrawGridWithPropertiesInRect(float majorSpacing,int tickCount, NSColor *gcolor, NSRect rect, NSPoint gridOrigin);
void DBDrawKnobAtPoint(NSPoint point, int knobType,float fraction);