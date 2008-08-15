//
//  DBDrawingExtensions.m
//  DrawBerry
//
//  Created by Raphael Bost on 07/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingExtensions.h"        

void DBDrawGridWithPropertiesInRect(float majorSpacing,int tickCount, NSColor *gcolor, NSRect rect, NSPoint gridOrigin) 
{
    int curMajLine, endMajLine;
    int curLine, endLine;
	float tickSpacing;
    NSBezierPath *majGridPath = [NSBezierPath bezierPath];
    NSBezierPath *gridPath = [NSBezierPath bezierPath];

    [gcolor set];  
	tickSpacing = majorSpacing / tickCount;

    // Columns
    curMajLine = floor((NSMinX(rect) - gridOrigin.x) / majorSpacing);
//	NSLog(@"curMajLine %d", curMajLine);
//	curMajLine = 0;
//	curMajLine = ceil((NSMinX(rect) - gridOrigin.x) / majorSpacing);
//	endMajLine = floor((NSMaxX(rect) - gridOrigin.x) / majorSpacing);
    endMajLine = floor((NSMaxX(rect) - gridOrigin.x) / majorSpacing);
// 	NSLog(@"endMajLine %d", endMajLine);

    for (; curMajLine-1 <=endMajLine; curMajLine++) {
        
		if(curMajLine ){
			
		}
		[majGridPath moveToPoint:NSMakePoint((curMajLine * majorSpacing) + gridOrigin.x, NSMinY(rect))];
        [majGridPath lineToPoint:NSMakePoint((curMajLine * majorSpacing) + gridOrigin.x, NSMaxY(rect))];

		curLine = 1;
		endLine = MIN(tickCount, ceilf((NSMaxX(rect)- ((curMajLine * majorSpacing)))/tickSpacing));

		for(; curLine < endLine; curLine++ )
		{
		    [gridPath moveToPoint:NSMakePoint((curMajLine * majorSpacing) + (curLine * tickSpacing) + gridOrigin.x, NSMinY(rect))];
            [gridPath lineToPoint:NSMakePoint((curMajLine * majorSpacing) + (curLine * tickSpacing) + gridOrigin.x, NSMaxY(rect))];  
		}
    }

    // Rows
    curMajLine = floor((NSMinY(rect) - gridOrigin.y) / majorSpacing);
    endMajLine = floor((NSMaxY(rect) - gridOrigin.y) / majorSpacing);
 	
   	for (; curMajLine<=endMajLine; curMajLine++) {
        [majGridPath moveToPoint:NSMakePoint(NSMinX(rect), (curMajLine * majorSpacing) + gridOrigin.y)];
        [majGridPath lineToPoint:NSMakePoint(NSMaxX(rect), (curMajLine * majorSpacing) + gridOrigin.y)];

		curLine = 1;
		endLine = MIN(tickCount, ceilf((NSMaxY(rect)- ((curMajLine * majorSpacing)))/tickSpacing));

  		for(; curLine < endLine; curLine++ )
		{       
			[gridPath moveToPoint:NSMakePoint(NSMinX(rect), (curMajLine * majorSpacing) + (curLine * tickSpacing) + gridOrigin.y)];
	        [gridPath lineToPoint:NSMakePoint(NSMaxX(rect), (curMajLine * majorSpacing) + (curLine * tickSpacing) + gridOrigin.y)];
		}
    }

    [majGridPath setLineWidth:1.0];
    [majGridPath stroke];
    [gridPath setLineWidth:.5];
    [gridPath stroke];
}

void DBDrawKnobAtPoint(NSPoint point, int knobType,float fraction){
	NSImage *knobImage;
	
	knobImage = [NSImage imageNamed:@"knob"];
	
	[knobImage drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction];
}   