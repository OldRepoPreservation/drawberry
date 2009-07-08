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
	int i;
    int curLine, endLine;
	float tickSpacing;
    NSBezierPath *majGridPath = [NSBezierPath bezierPath];
    NSBezierPath *gridPath = [NSBezierPath bezierPath];

    [gcolor set];  
	tickSpacing = majorSpacing / tickCount;

    // Columns
    curMajLine = floor((NSMinX(rect) - gridOrigin.x) / majorSpacing)+1;
    endMajLine = floor((NSMaxX(rect) - gridOrigin.x) / majorSpacing);

    for (i = 0; curMajLine+i <= endMajLine; i++) {
        
		if(i > 0 ){ // don't display the first line
			[majGridPath moveToPoint:NSMakePoint(((curMajLine+i) * majorSpacing) + gridOrigin.x, NSMinY(rect))];
			[majGridPath lineToPoint:NSMakePoint(((curMajLine+i) * majorSpacing) + gridOrigin.x, NSMaxY(rect))];
		}

		curLine = 1;
		endLine = MIN(tickCount, ceilf((NSMaxX(rect)- (((curMajLine+i) * majorSpacing)))/tickSpacing));

		for(; curLine < endLine; curLine++ )
		{
		    [gridPath moveToPoint:NSMakePoint(((curMajLine+i) * majorSpacing) + (curLine * tickSpacing) + gridOrigin.x, NSMinY(rect))];
            [gridPath lineToPoint:NSMakePoint(((curMajLine+i) * majorSpacing) + (curLine * tickSpacing) + gridOrigin.x, NSMaxY(rect))];  
		}
    }

    // Rows
    curMajLine = floor((NSMinY(rect) - gridOrigin.y) / majorSpacing)+1;
    endMajLine = floor((NSMaxY(rect) - gridOrigin.y) / majorSpacing);
 	
   	for (i = 0 ; curMajLine+i <=endMajLine; i++) {
 		if(i > 0 ){ // don't display the first line
			[majGridPath moveToPoint:NSMakePoint(NSMinX(rect), ((curMajLine+i) * majorSpacing) + gridOrigin.y)];
			[majGridPath lineToPoint:NSMakePoint(NSMaxX(rect), ((curMajLine+i) * majorSpacing) + gridOrigin.y)];
		}
		curLine = 1;
		endLine = MIN(tickCount, ceilf((NSMaxY(rect)- (((curMajLine+i) * majorSpacing)))/tickSpacing));

  		for(; curLine < endLine; curLine++ )
		{       
			[gridPath moveToPoint:NSMakePoint(NSMinX(rect), ((curMajLine+i) * majorSpacing) + (curLine * tickSpacing) + gridOrigin.y)];
	        [gridPath lineToPoint:NSMakePoint(NSMaxX(rect), ((curMajLine+i) * majorSpacing) + (curLine * tickSpacing) + gridOrigin.y)];
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