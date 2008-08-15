//
//  NSBezierPath+Extensions.m
//  DrawBerry
//
//  Created by Raphael Bost on 27/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSBezierPath+Extensions.h"
#import "AJHBezierUtils.h"
#import "GCGeometryUtilities.h"   
@implementation NSBezierPath (DBExtensions)

/*+ (NSArray *)bezierPathWithLineArrowHeadOfstartPoint:(NSPoint)startPoint endPoint:(NSPoint)endPoint startLineStyle:(DBArrowStyle)lineTailStyle endLineStyle:(DBArrowStyle)lineHeadStyle width:(float)lineWidth
{
	double start_H_Left_r,start_V_Top_r,end_H_Right_r,end_V_Bottom_r;
    long line_Width_l;
    start_H_Left_r = startPoint.x;
    start_V_Top_r = startPoint.y;
    end_H_Right_r = endPoint.x;
    end_V_Bottom_r = endPoint.y;
    line_Width_l = lineWidth; //This method works best for lines widths <= 3
    NSString *startingSide = [NSString string];

    if ( start_H_Left_r <= end_H_Right_r )
        startingSide = [NSString stringWithFormat:@"left"];
    else
        if ( start_H_Left_r >= end_H_Right_r )
            startingSide = [NSString stringWithFormat:@"right"];

    double slope;
    slope = ( end_V_Bottom_r - start_V_Top_r )/((start_H_Left_r - end_H_Right_r ) + 0.1);
    //sets the slope to a “high" number when the line is horizontal or vertical
    if ( slope > 350 )
        slope = 350;
    else
        if ( slope < -350 )
            slope = -350;

    // This sets the length of the arrow from the tip to the base.
    double adjR,oppR,startingPointR,xStartingPointR = 0.0f,yStartingPointR = 0.0f;

    // the length of the arrow is 8 pixels + the line width
    startingPointR = 20 + line_Width_l;

    adjR = sqrt( (pow(startingPointR,2))/pow((abs(slope) + 1),2) ); // deltaX
    oppR = slope * adjR; // deltaY

    // This adjusts the starting point for the base of the arrow so it is correctly oriented on the line.
    if ( [startingSide isEqualToString: @"left"] ) {
        xStartingPointR = adjR;
        yStartingPointR = oppR;
    } else
        if ( [startingSide isEqualToString: @"right"] ) {
            xStartingPointR = -adjR;
            yStartingPointR = -oppR;
        } else
            NSLog(@"shouldnt happen");

    // This calculates the base of the arrow
    double lengthOfPerpendicularR,tangentLineLengthR;
    tangentLineLengthR = 10 + line_Width_l;
    lengthOfPerpendicularR = sqrt( (pow(tangentLineLengthR,2))/(4*(pow(slope,2) + 1)));

    //This calculates the base of the arrow for the polygon
    double pStart_H_Left_r,pStart_V_Top_r,pEnd_H_Right_r,pEnd_V_Bottom_r;

    pStart_H_Left_r = end_H_Right_r - xStartingPointR - ( lengthOfPerpendicularR * slope );
    pStart_V_Top_r = end_V_Bottom_r + yStartingPointR - ( lengthOfPerpendicularR );
    pEnd_H_Right_r = end_H_Right_r - xStartingPointR + ( lengthOfPerpendicularR * slope );
    pEnd_V_Bottom_r = end_V_Bottom_r + yStartingPointR + ( lengthOfPerpendicularR );

    NSBezierPath *arrowHead,*arrowTail;
    arrowHead = [NSBezierPath bezierPath];
	arrowTail = [NSBezierPath bezierPath];
	
    [arrowHead moveToPoint:endPoint];
    if ( lineHeadStyle == DBArrowStyle ) {
        [arrowHead lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowHead lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowHead lineToPoint:endPoint];
    } else if ( lineHeadStyle == DBCircleStyle ) {
        [arrowHead appendBezierPathWithOvalInRect:NSMakeRect(endPoint.x-2.5f,endPoint.y-2.5f,5.0f,5.0f)];
    } else if ( lineHeadStyle == DBOpenArrowStyle ) {
        [arrowHead lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowHead lineToPoint:endPoint];
        [arrowHead lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowHead lineToPoint:endPoint];
    } else if ( lineHeadStyle == DBDiamondStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = endPoint.x-((endPoint.x-xValue)*2);
        float pointY = endPoint.y-((endPoint.y-yValue)*2);
        [arrowHead lineToPoint:s1];
        [arrowHead lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowHead lineToPoint:s2];
        [arrowHead lineToPoint:endPoint];
    } else if ( lineHeadStyle == DBPointYArrowStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = endPoint.x-((endPoint.x-xValue)/2);
        float pointY = endPoint.y-((endPoint.y-yValue)/2);
        [arrowHead lineToPoint:s1];
        [arrowHead lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowHead lineToPoint:s2];
        [arrowHead lineToPoint:endPoint];
    }

    [arrowTail moveToPoint:startPoint];

    pStart_H_Left_r = start_H_Left_r + xStartingPointR + ( lengthOfPerpendicularR * slope );
    pStart_V_Top_r = start_V_Top_r - yStartingPointR + ( lengthOfPerpendicularR );
    pEnd_H_Right_r = start_H_Left_r + xStartingPointR - ( lengthOfPerpendicularR * slope );
    pEnd_V_Bottom_r = start_V_Top_r - yStartingPointR - ( lengthOfPerpendicularR );

    if ( lineTailStyle == DBArrowStyle ) {
        [arrowTail lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowTail lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowTail lineToPoint:startPoint];
    } else if ( lineTailStyle == DBCircleStyle ) {
        [arrowTail appendBezierPathWithOvalInRect:NSMakeRect(startPoint.x-2.5f,startPoint.y-2.5f,5.0f,5.0f)];
    } else if ( lineTailStyle == DBOpenArrowStyle ) {
        [arrowTail lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowTail lineToPoint:startPoint];
        [arrowTail lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowTail lineToPoint:startPoint];
    } else if ( lineTailStyle == DBDiamondStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = startPoint.x-((startPoint.x-xValue)*2);
        float pointY = startPoint.y-((startPoint.y-yValue)*2);
        [arrowTail lineToPoint:s1];
        [arrowTail lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowTail lineToPoint:s2];
        [arrowTail lineToPoint:startPoint];
    } else if ( lineTailStyle == DBPointYArrowStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = startPoint.x-((startPoint.x-xValue)/2);
        float pointY = startPoint.y-((startPoint.y-yValue)/2);
        [arrowTail lineToPoint:s1];
        [arrowTail lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowTail lineToPoint:s2];
        [arrowTail lineToPoint:startPoint];
    }

    return [NSArray arrayWithObjects:arrowHead,arrowTail,nil];
}

*/

+ (NSBezierPath *)bezierPathWithArrowOnSegment:(NSPoint)startPoint endPoint:(NSPoint)endPoint arrowType:(DBArrowStyle)arrowStyle width:(float)lineWidth options:(DBArrowOptions)options
{
	NSPoint arrowBase;
	NSPoint point1, point2;
	float arrowLength;
	float arrowAngle;
	float arrowBaseLength;
	float slope, perpSlope;
	NSBezierPath *path = [NSBezierPath bezierPath];
	
/*	arrowLength = 20.0;
	arrowAngle = 30.0;
*/ 	
	arrowLength = options.arrowLength;
	arrowAngle = options.arrowAngle;

	slope = (startPoint.y - endPoint.y)/(startPoint.x - endPoint.x);
	
	if(slope > 1000){
		slope = -1000;
	}else if(slope < -1000){
		slope = 1000;
	}	
	// get the slope of a perpendicular ...
	perpSlope = -(1.0/slope);
	
	// NSLog(@"slope : %g, %g", slope, perpSlope); 
	
    // get arrowAngle in degrees and then the arrowBaseLength
	arrowAngle = arrowAngle*(M_PI/180);
	arrowBaseLength = tan(arrowAngle/2)*arrowLength;
//	NSLog(@"arrowBaseLength %g", sin(arrowAngle));
	
 	arrowBase.x = arrowLength/(sqrt(slope*slope + 1.0));
	arrowBase.y = slope*arrowBase.x; 
	
	if(startPoint.x > endPoint.x){ // in this case, we take the point at the opposite
		arrowBase.x = -arrowBase.x;
		arrowBase.y = -arrowBase.y;
	}
	// translate (the origin is startPoint)	
	arrowBase.x += startPoint.x;
	arrowBase.y += startPoint.y;
	
	point1.x = arrowBaseLength/(sqrt(perpSlope*perpSlope + 1.0));
	point1.y = perpSlope*point1.x; 
 	point2.x = -point1.x;
	point2.y = -point1.y;
	
	point1.x += arrowBase.x;
	point1.y += arrowBase.y;
	point2.x += arrowBase.x;
	point2.y += arrowBase.y;
	
	if(arrowStyle == DBFullArrowStyle){ 
		[path moveToPoint:startPoint];
		[path lineToPoint:point1];
		[path lineToPoint:point2];
		[path closePath];
    }else if(arrowStyle == DBCircleStyle){
		NSPoint circleCenter;
		circleCenter.x = (startPoint.x + arrowBase.x)/2.0;
		circleCenter.y = (startPoint.y + arrowBase.y)/2.0;
		
    	[path appendBezierPathWithArcWithCenter:circleCenter radius:(arrowLength/2.0) startAngle:0 endAngle:360];
    
	}else if(arrowStyle == DBOpenArrowStyle){
    	[path moveToPoint:point1];
		[path lineToPoint:startPoint];
		[path lineToPoint:point2];
    }else if(arrowStyle == DBDiamondStyle){
		point1.x += (startPoint.x - arrowBase.x)/2.0;
		point1.y += (startPoint.y - arrowBase.y)/2.0;
		point2.x += (startPoint.x - arrowBase.x)/2.0;
		point2.y += (startPoint.y - arrowBase.y)/2.0;
		[path moveToPoint:point1];
		[path lineToPoint:startPoint];
		[path lineToPoint:point2];				
		[path lineToPoint:arrowBase];
		[path closePath];   			
	}else if(arrowStyle == DBPointYArrowStyle){
		point1.x += 2*(startPoint.x - arrowBase.x);
		point1.y += 2*(startPoint.y - arrowBase.y);
		point2.x += 2*(startPoint.x - arrowBase.x);
		point2.y += 2*(startPoint.y - arrowBase.y);
		[path moveToPoint:point1];
		[path lineToPoint:startPoint];
		[path lineToPoint:point2];
    }	
	return path;
}

- (NSPoint)lastPoint
{
	NSPoint points[3];
	int i;
	NSBezierPathElement element;
   	
	element = [self elementAtIndex:[self elementCount]-1 associatedPoints:points];
    
	if(element == NSClosePathBezierPathElement){
		return [self firstPoint];
	}                            
	
	for( i = 1; i <= [self elementCount]; i++ )
	{
		element = [self elementAtIndex:[self elementCount]-i associatedPoints:points];
		
		if(element == NSLineToBezierPathElement){
			return points[0];
		}else if(element == NSCurveToBezierPathElement){
			return points[2];
		}
	}
	
	return NSZeroPoint;
}

- (NSBezierPath *)startArrowWithType:(DBArrowStyle)type options:(DBArrowOptions)options
{
	NSPoint firstPoint, secondPoint;
	NSPoint points[3];
  	NSBezierPathElement element = [self elementAtIndex:0
				    associatedPoints:points];
 
	if([self elementCount] < 2)
		return nil;
	
	secondPoint = firstPoint = NSZeroPoint;
	if(element == NSMoveToBezierPathElement){
		firstPoint = points[0];
		element = [self elementAtIndex:1 associatedPoints:points];
	}
		
	if(element == NSLineToBezierPathElement){
		secondPoint = points[0];
	}else if(element == NSCurveToBezierPathElement){
		secondPoint = points[0];
	}
    
	NSBezierPath *path;
	int count;
	float phase;
	float *pattern;
	
	path = [NSBezierPath bezierPathWithArrowOnSegment:firstPoint endPoint:secondPoint arrowType:type width:[self lineWidth] options:options];
	[path setLineWidth:[self lineWidth]];
	[path setLineJoinStyle:[self lineJoinStyle]]; 
	[path setLineCapStyle:[self lineCapStyle]];
	[self getLineDash:pattern count:&count phase:&phase];
	[path setLineDash:pattern count:count phase:phase];
	 
	return path;
}

- (NSBezierPath *)endArrowWithType:(DBArrowStyle)type options:(DBArrowOptions)options
{
	NSBezierPath *path = [self bezierPathByReversingPath];
	NSBezierPath *arrow = [path startArrowWithType:type options:options];
	
	return arrow;
}
@end

@implementation NSBezierPath(RoundedRectangle)

+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect)aRect cornerRadius: (float)radius inCorners:(OSCornerType)corners
{
	NSBezierPath* path = [self bezierPath];
	radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
	NSRect rect = NSInsetRect(aRect, radius, radius);
	
	if (corners & OSBottomLeftCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & OSBottomRightCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}

	if (corners & OSTopRightCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & OSTopLeftCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	[path closePath];
	return path;	
}

+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)aRect cornerRadius:(float)radius
{
	return [NSBezierPath bezierPathWithRoundedRect:aRect cornerRadius:radius inCorners:OSTopLeftCorner | OSTopRightCorner | OSBottomLeftCorner | OSBottomRightCorner];
}

@end

@implementation NSBezierPath (Text)

- (float) slopeStartingPath
{
	// returns the slope starting the path
	
	if ([self elementCount] > 1)
	{
		NSPoint	ap[3], lp[3];

		[self elementAtIndex:0 associatedPoints:ap];
		[self elementAtIndex:1 associatedPoints:lp];
		
		return Slope( ap[0], lp[0] );
	}
	else
		return 0;
}

- (void)drawTextOnPath:(NSAttributedString*) str yOffset:(float) dy
{
	NSBezierPath* textPath = [self bezierPathWithTextOnPath:str yOffset:dy];
	
	// render the text path using the foreground colour and shadow of the attributed string
	
	NSColor* textColour = [str attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
	
	if ( textColour )
		[textColour set];
	else
		[[NSColor blackColor] set];
	
	// any shadow?
	
//	NSShadow* textShadow = [str attribute:NSShadowAttributeName atIndex:0 effectiveRange:NULL];
	
	// if ( textShadow )
	// 	[textShadow setAbsoluteFlipped:YES];
	
	// draw it

	[textPath fill];
	
	// any stroke?
		
	NSDictionary*	attrs = [str attributesAtIndex:0 effectiveRange:NULL];
	
	if ([attrs objectForKey:NSStrokeWidthAttributeName] != nil )
	{
		float stroke = [[str attribute:NSStrokeWidthAttributeName atIndex:0 effectiveRange:NULL] floatValue];
		
		if ( stroke > 0 )
		{
			// !!! the value is in percent of font point size, not absolute stroke width
			
			NSFont* font = [str attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
			
			float strokeWidth = ([font pointSize] * stroke ) / 100.0;
			
			textColour = [str attribute:NSStrokeColorAttributeName atIndex:0 effectiveRange:NULL];
			if ( textColour )
				[textColour set];
				
			[textPath setLineWidth:strokeWidth];
			[textPath stroke];
		}
	}
}


- (void)drawStringOnPath:(NSString*) str
{
	[self drawStringOnPath:str attributes:nil];
}


- (void)drawStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs;
{
	NSAttributedString* as = [[NSAttributedString alloc] initWithString:str attributes:attrs];
	[self drawTextOnPath:as yOffset:0];
	[as release];
}


- (NSBezierPath*)bezierPathWithTextOnPath:(NSAttributedString*) str yOffset:(float) dy
{
	// returns a new path consisting of the glyphs laid out along the current path from <str>
	
	if([self elementCount] < 2 || [str length] < 1 )
		return nil;	// nothing useful to do
		
	NSBezierPath*	newPath = [NSBezierPath bezierPath];
	NSPoint			start;
	
	[self elementAtIndex:0 associatedPoints:&start];
	[newPath moveToPoint:start];
	
	// init temporary text system
			
    NSTextStorage* ts = [[NSTextStorage alloc] initWithAttributedString:str];
    NSLayoutManager* lm = [[NSLayoutManager alloc] init];
    NSTextContainer* tc = [[NSTextContainer alloc] init];
    [lm addTextContainer:tc];
    [tc release];
    [ts addLayoutManager:lm];
    [lm release];
    [lm setUsesScreenFonts:NO]; 

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSBezierPath*	temp, *glyphTemp;
	NSFont*			font = [str attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
	
	unsigned glyphIndex;
	NSRect	gbr;
	
	gbr.size = NSMakeSize([self length], [lm defaultLineHeightForFont:font]);
	gbr.origin = NSZeroPoint;
	
	// set container size so that the width is the path's length - this will honour left/right/centre paragraphs setting
	// and truncate at the end of the last whole word that can be fitted.
	
	[tc setContainerSize:gbr.size];
	NSRange glyphRange = [lm glyphRangeForBoundingRect:gbr inTextContainer:tc];
	
	// lay down the glyphs along the path
	
    for (glyphIndex = glyphRange.location; glyphIndex < NSMaxRange(glyphRange); glyphIndex++)
	{
		NSRect lineFragmentRect = [lm lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
		NSPoint viewLocation, layoutLocation = [lm locationForGlyphAtIndex:glyphIndex];
		NSGlyph	glyph;
		
        layoutLocation.x += lineFragmentRect.origin.x;
        layoutLocation.y += lineFragmentRect.origin.y;
		
		gbr = [lm boundingRectForGlyphRange:NSMakeRange( glyphIndex, 1) inTextContainer:tc];
		float half = gbr.size.width * 0.5f;
		
		// if the character width is zero or -ve, skip it - some control glyphs appear to need  suppressing in this way
		
		if ( gbr.size.width > 0 )
		{
			// get a shortened path that starts at the character location
			
			temp = [self bezierPathByTrimmingFromLength:layoutLocation.x + half];
			
			// if no more room on path, stop laying glyphs (will not normally occur as glyph range is set to one line)
			
			if ([temp length] < half )
				break;
				
			[temp elementAtIndex:0 associatedPoints:&viewLocation];
			float angle = [temp slopeStartingPath];
			
			// view location needs to be projected back along the baseline tangent by half the character width to align
			// the character based on the middle of the glyph instead of the left edge
			
			viewLocation.x -= half * cos( angle );
			viewLocation.y -= half * sin( angle );
			
			NSAffineTransform *transform = [NSAffineTransform transform];
			[transform translateXBy:viewLocation.x yBy:viewLocation.y];
			[transform rotateByRadians:angle];
			[transform scaleXBy:1 yBy:-1];		// assumes destination is flipped
			
			glyph = [lm glyphAtIndex:glyphIndex];
			glyphTemp = [[NSBezierPath alloc] init];
			[glyphTemp moveToPoint:NSMakePoint( 0, dy )];
			[glyphTemp appendBezierPathWithGlyph:glyph inFont:font];
			[glyphTemp transformUsingAffineTransform:transform];
			
			[newPath appendBezierPath:glyphTemp];
			[glyphTemp release];
		}
    }
	[pool release];
	[ts release];
	
	return newPath;
}


- (NSBezierPath*)bezierPathWithStringOnPath:(NSString*) str
{
	return [self bezierPathWithStringOnPath:str attributes:nil];
}


- (NSBezierPath*)bezierPathWithStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs
{
	NSAttributedString* as = [[NSAttributedString alloc] initWithString:str attributes:attrs];
	NSBezierPath*		np = [self bezierPathWithTextOnPath:as yOffset:0];
	[as release];
	return np;
}

@end

DBArrowOptions DBMakeArrowOptions(float arrowLength, float arrowAngle)
{
	DBArrowOptions options;
	
	options.arrowLength = arrowLength;
	options.arrowAngle = arrowAngle;
	
	return options;
}

DBArrowOptions DBDefaultArrowOptions()
{
	return DBMakeArrowOptions(20.0, 30.0);
}