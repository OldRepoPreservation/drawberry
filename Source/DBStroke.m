//
//  DBStroke.m
//  DrawBerry
//
//  Created by Raphael Bost on 19/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBStroke.h"

#import "DBShape.h"

#import "NSBezierPath+Extensions.h"
   
@class DBPolyline;

@implementation DBStroke
+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObject:@"strokeMode"] triggerChangeNotificationsForDependentKey:@"needsColor"];
	[self setKeys:[NSArray arrayWithObject:@"strokeMode"] triggerChangeNotificationsForDependentKey:@"needsPatternImage"];
}

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
        slope = -350;
    else
        if ( slope < -350 )
            slope = 350;
   
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
            NSLog(@"shouldn t happen");
   
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
  	

    [arrowHead moveToPoint:startPoint];


    if ( lineTailStyle == DBFullArrowStyle ) {
        [arrowHead lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowHead lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowHead lineToPoint:startPoint];
    } else if ( lineTailStyle == DBCircleStyle ) {
        [arrowHead appendBezierPathWithOvalInRect:NSMakeRect(startPoint.x-2.5f,startPoint.y-2.5f,5.0f,5.0f)];
    } else if ( lineTailStyle == DBOpenArrowStyle ) {
        [arrowHead lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowHead lineToPoint:startPoint];
        [arrowHead lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowHead lineToPoint:startPoint];
    } else if ( lineTailStyle == DBDiamondStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = startPoint.x-((startPoint.x-xValue)*2);
        float pointY = startPoint.y-((startPoint.y-yValue)*2);
        [arrowHead lineToPoint:s1];
        [arrowHead lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowHead lineToPoint:s2];
        [arrowHead lineToPoint:startPoint];
    } else if ( lineTailStyle == DBPointYArrowStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = startPoint.x-((startPoint.x-xValue)/2);
        float pointY = startPoint.y-((startPoint.y-yValue)/2);
        [arrowHead lineToPoint:s1];
        [arrowHead lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowHead lineToPoint:s2];
        [arrowHead lineToPoint:startPoint];
    }
    
    [arrowTail moveToPoint:endPoint];

    pStart_H_Left_r = start_H_Left_r + xStartingPointR + ( lengthOfPerpendicularR * slope );
    pStart_V_Top_r = start_V_Top_r - yStartingPointR + ( lengthOfPerpendicularR );
    pEnd_H_Right_r = start_H_Left_r + xStartingPointR - ( lengthOfPerpendicularR * slope );
    pEnd_V_Bottom_r = start_V_Top_r - yStartingPointR - ( lengthOfPerpendicularR );

    if ( lineHeadStyle == DBArrowStyle ) {
        [arrowTail lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowTail lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowTail lineToPoint:endPoint];
    } else if ( lineHeadStyle == DBCircleStyle ) {
        [arrowTail appendBezierPathWithOvalInRect:NSMakeRect(endPoint.x-2.5f,endPoint.y-2.5f,5.0f,5.0f)];
    } else if ( lineHeadStyle == DBOpenArrowStyle ) {
        [arrowTail lineToPoint:NSMakePoint(pStart_H_Left_r,pStart_V_Top_r)];
        [arrowTail lineToPoint:endPoint];
        [arrowTail lineToPoint:NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r)];
        [arrowTail lineToPoint:endPoint];
    } else if ( lineHeadStyle == DBDiamondStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = endPoint.x-((endPoint.x-xValue)*2);
        float pointY = endPoint.y-((endPoint.y-yValue)*2);
        [arrowTail lineToPoint:s1];
        [arrowTail lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowTail lineToPoint:s2];
        [arrowTail lineToPoint:endPoint];
    } else if ( lineHeadStyle == DBPointYArrowStyle ) {
        NSPoint s1 = NSMakePoint(pStart_H_Left_r,pStart_V_Top_r);
        NSPoint s2 = NSMakePoint(pEnd_H_Right_r,pEnd_V_Bottom_r);
        float xV = s2.x-s1.x;
        float xValue = s1.x+(xV/2.0f);
        float yV = s2.y-s1.y;
        float yValue = s1.y+(yV/2.0f);
        float pointX = endPoint.x-((endPoint.x-xValue)/2);
        float pointY = endPoint.y-((endPoint.y-yValue)/2);
        [arrowTail lineToPoint:s1];
        [arrowTail lineToPoint:NSMakePoint(pointX,pointY)];
        [arrowTail lineToPoint:s2];
        [arrowTail lineToPoint:endPoint];
    }
    return [NSArray arrayWithObjects:arrowHead,arrowTail,nil];
}
*/
- (id)initWithShape:(DBShape *)shape
{
	self = [super init];
	               
	// do not retain shape or there will be a retain loop
	
	_shape = shape;
	
	_stroke = YES;
	
	_strokeMode = 0;
	_lineWidth = 1.0;
	_lineJoinStyle = NSMiterLineJoinStyle;
	_lineCapStyle = NSButtLineCapStyle;
	
	_arrowStyle = 0;
	_dashStyle = 0;
	
	_strokeColor = [[NSColor blackColor] retain];            
	_patternImage = nil;
	
	_showStartArrow = NO;
	_showEndArrow = NO;
	_startArrowStyle = 0;
	_endArrowStyle = 0;
	[self setStartArrowFillColor:[NSColor whiteColor]];
	[self setEndArrowFillColor:[NSColor whiteColor]];
    _strokeStartArrow = YES;
	_strokeEndArrow = YES;
    _fillStartArrow = YES;
    _fillEndArrow = YES;

	_textOffset = 2.0;
	
	return self;
}

- (void)dealloc
{
	[_strokeColor release];
	[_patternImage release];
	[_text release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	DBStroke *stroke = [[DBStroke alloc] init];
	
	[stroke setStrokeMode:[self strokeMode]];
	[stroke setLineWidth:[self lineWidth]];
	[stroke setLineJoinStyle:[self lineJoinStyle]];
	[stroke setLineCapStyle:[self lineCapStyle]];
	[stroke setArrowStyle:[self arrowStyle]];
	[stroke setDashStyle:[self dashStyle]];
	[stroke setStrokeColor:[[[self strokeColor] copy] autorelease]];
	[stroke setPatternImage:[[[self patternImage] copy] autorelease]];
    
	[stroke setShowStartArrow:[self showStartArrow]];
	[stroke setShowEndArrow:[self showEndArrow]];
	[stroke setStartArrowStyle:[self startArrowStyle]];
	[stroke setEndArrowStyle:[self endArrowStyle]];
   	[stroke setStartArrowFillColor:[[[self startArrowFillColor] copy] autorelease]];
   	[stroke setEndArrowFillColor:[[[self endArrowFillColor] copy] autorelease]];
	[stroke setStrokeStartArrow:[self strokeStartArrow]];
	[stroke setStrokeEndArrow:[self strokeEndArrow]];
	[stroke setFillStartArrow:[self fillStartArrow]];
	[stroke setFillEndArrow:[self fillEndArrow]];
    
   	[stroke setText:[[[self text] copy] autorelease]];
	[stroke setTextOffset:[self textOffset]];

	return stroke;
} 

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	_strokeMode = [decoder decodeIntForKey:@"Stroke Mode"];            
	_lineWidth = [decoder decodeFloatForKey:@"Line Width"];
 	_lineJoinStyle = [decoder decodeIntForKey:@"Line Join Style"];            
	_lineCapStyle = [decoder decodeIntForKey:@"Line Cap Style"];            
	_dashStyle = [decoder decodeIntForKey:@"Dash Style"];            
	_strokeColor = [[decoder decodeObjectForKey:@"Stroke Color"] retain];
	_patternImage = [[decoder decodeObjectForKey:@"Pattern Image"] retain];
	
	_showStartArrow = [decoder decodeBoolForKey:@"Show Start Arrow"];
	_showEndArrow = [decoder decodeBoolForKey:@"Show End Arrow"];
	_strokeStartArrow = [decoder decodeBoolForKey:@"Stroke Start Arrow"];
	_strokeEndArrow = [decoder decodeBoolForKey:@"Stroke End Arrow"];
	_fillStartArrow = [decoder decodeBoolForKey:@"Fill Start Arrow"];
	_fillEndArrow = [decoder decodeBoolForKey:@"Fill End Arrow"];
	_startArrowStyle = [decoder decodeIntForKey:@"Start Arrow Style"];            
	_endArrowStyle = [decoder decodeIntForKey:@"End Arrow Style"];            
	_startArrowFillColor = [[decoder decodeObjectForKey:@"Start Arrow Fill Color"] retain];
	_endArrowFillColor = [[decoder decodeObjectForKey:@"End Arrow Fill Color"] retain];
	
	_text = [[decoder decodeObjectForKey:@"Stroke Text"] retain];
	_textOffset = [decoder decodeFloatForKey:@"Text Offset"];
	
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:_strokeMode forKey:@"Stroke Mode"];
	[encoder encodeFloat:_lineWidth forKey:@"Line Width"];
	[encoder encodeInt:_lineJoinStyle forKey:@"Line Join Style"]; 
	[encoder encodeInt:_lineCapStyle forKey:@"Line Cap Style"]; 
	[encoder encodeInt:_dashStyle forKey:@"Dash Style"]; 
	[encoder encodeObject:_strokeColor forKey:@"Stroke Color"];
	[encoder encodeObject:_patternImage forKey:@"Pattern Image"];
    
	[encoder encodeBool:_showStartArrow forKey:@"Show Start Arrow"];
	[encoder encodeBool:_showEndArrow forKey:@"Show End Arrow"];
	[encoder encodeBool:_strokeStartArrow forKey:@"Stroke Start Arrow"];
	[encoder encodeBool:_strokeEndArrow forKey:@"Stroke End Arrow"];
	[encoder encodeBool:_fillStartArrow forKey:@"Fill Start Arrow"];
	[encoder encodeBool:_fillEndArrow forKey:@"Fill End Arrow"];
    [encoder encodeInt:_startArrowStyle forKey:@"Start Arrow Style"]; 
	[encoder encodeInt:_endArrowStyle forKey:@"End Arrow Style"]; 
	[encoder encodeObject:_startArrowFillColor forKey:@"Start Arrow Fill Color"];
	[encoder encodeObject:_endArrowFillColor forKey:@"End Arrow Fill Color"];


	[encoder encodeObject:_text forKey:@"Stroke Text"];
	[encoder encodeFloat:_textOffset forKey:@"Text Offset"];
}

#pragma mark Accessors
- (BOOL)stroke
{
	return _stroke;
}

- (void)setStroke:(BOOL)newStroke
{
	_stroke = newStroke;
}

- (int)strokeMode
{
	return _strokeMode;
}

- (void)setStrokeMode:(int)newStrokeMode
{
	_strokeMode = newStrokeMode;
	[_shape strokeUpdated];
}

- (BOOL)needsColor
{
	return (_strokeMode == DBColorStrokeMode);
}   

- (BOOL)needsPatternImage
{
	return (_strokeMode == DBImagePatternStrokeMode);
}   

- (float)lineWidth
{
	return _lineWidth;
}

- (void)setLineWidth:(float)newLineWidth
{
	_lineWidth = newLineWidth;
	[_shape strokeUpdated];
}

- (int)lineJoinStyle
{
	return _lineJoinStyle;
}

- (void)setLineJoinStyle:(int)newLineJoinStyle
{
	_lineJoinStyle = newLineJoinStyle;
	[_shape strokeUpdated];
}

- (int)lineCapStyle
{
	return _lineCapStyle;
}

- (void)setLineCapStyle:(int)newLineCapStyle
{
	_lineCapStyle = newLineCapStyle;
	[_shape strokeUpdated];
}

- (int)arrowStyle
{
	return _arrowStyle;
}

- (void)setArrowStyle:(int)newArrowStyle
{
	_arrowStyle = newArrowStyle;
	[_shape strokeUpdated];
}

- (int)dashStyle
{
	return _dashStyle;
}

- (void)setDashStyle:(int)newDashStyle
{
	_dashStyle = newDashStyle;
	[_shape strokeUpdated];
}

- (NSColor *)strokeColor
{
	return _strokeColor;
}

- (void)setStrokeColor:(NSColor *)newStrokeColor
{
	[newStrokeColor retain];
	[_strokeColor release];
	_strokeColor = newStrokeColor;
	[_shape strokeUpdated];
}

- (NSImage *)patternImage
{
	return _patternImage;
}

- (void)setPatternImage:(NSImage *)newPatternImage
{
	[newPatternImage retain];
	[_patternImage release];
	_patternImage = newPatternImage;
	[_shape strokeUpdated];
}

#pragma mark Arrows Accessors

- (BOOL)showStartArrow
{
	return _showStartArrow;
}

- (void)setShowStartArrow:(BOOL)newShowStartArrow
{
	_showStartArrow = newShowStartArrow;
	[_shape strokeUpdated];
}

- (BOOL)showEndArrow
{
	return _showEndArrow;
}

- (void)setShowEndArrow:(BOOL)newShowEndArrow
{
	_showEndArrow = newShowEndArrow;
	[_shape strokeUpdated];
}

- (DBArrowStyle)startArrowStyle
{
	return _startArrowStyle;
}

- (void)setStartArrowStyle:(DBArrowStyle)newStartArrowStyle
{
	_startArrowStyle = newStartArrowStyle;
	[_shape strokeUpdated];
}

- (DBArrowStyle)endArrowStyle
{
	return _endArrowStyle;
}

- (void)setEndArrowStyle:(DBArrowStyle)newEndArrowStyle
{
	_endArrowStyle = newEndArrowStyle;
	[_shape strokeUpdated];
}

- (NSColor *)startArrowFillColor
{
	return _startArrowFillColor;
}

- (void)setStartArrowFillColor:(NSColor *)newStartArrowFillColor
{
	[newStartArrowFillColor retain];
	[_startArrowFillColor release];
	_startArrowFillColor = newStartArrowFillColor;
	[_shape strokeUpdated];
}

- (NSColor *)endArrowFillColor
{
	return _endArrowFillColor;
}

- (void)setEndArrowFillColor:(NSColor *)newEndArrowFillColor
{
	[newEndArrowFillColor retain];
	[_endArrowFillColor release];
	_endArrowFillColor = newEndArrowFillColor;
	[_shape strokeUpdated];
}

- (BOOL)strokeStartArrow
{
	return _strokeStartArrow;
}

- (void)setStrokeStartArrow:(BOOL)newStrokeStartArrow
{
	_strokeStartArrow = newStrokeStartArrow;
	[_shape strokeUpdated];
}

- (BOOL)strokeEndArrow
{
	return _strokeEndArrow;
}

- (void)setStrokeEndArrow:(BOOL)newStrokeEndArrow
{
	_strokeEndArrow = newStrokeEndArrow;
	[_shape strokeUpdated];
}

- (BOOL)fillStartArrow
{
	return _fillStartArrow;
}

- (void)setFillStartArrow:(BOOL)newFillStartArrow
{
	_fillStartArrow = newFillStartArrow;
	[_shape strokeUpdated];
}

- (BOOL)fillEndArrow
{
	return _fillEndArrow;
}

- (void)setFillEndArrow:(BOOL)newFillEndArrow
{
	_fillEndArrow = newFillEndArrow;
	[_shape strokeUpdated];
}

- (DBShape *)shape
{
	return _shape;
}

- (void)setShape:(DBShape *)newShape
{                   
	[_shape setStroke:nil];
	_shape = newShape;
   	[_shape strokeUpdated];
} 

# pragma mark  Text

- (NSAttributedString *)text
{
	return _text;
}

- (void)setText:(NSAttributedString *)newText
{
	[_text release];
	_text = [newText mutableCopy];
	
	[_textPath release];
	_textPath = nil ;
	[_shape strokeUpdated];
}

- (float)textOffset
{
	return _textOffset;
}

- (void)setTextOffset:(float)newTextOffset
{
	_textOffset = newTextOffset;
	[_shape strokeUpdated];
}

- (BOOL)flipText
{
	return _flipText;
}

- (void)setFlipText:(BOOL)newFlipText
{
	_flipText = newFlipText;
	[_shape strokeUpdated] ;
}

- (BOOL)toggleFlipText
{
	return NO;
}             

- (void)setToggleFlipText:(BOOL)flag
{
	[self setFlipText:!_flipText];
}   
                         
- (int)textPosition
{
	return _textPosition;
}

- (void)setTextPosition:(int)newTextPosition
{
	_textPosition = newTextPosition;
	[_shape strokeUpdated];
}

- (NSTextAlignment)textAlignment
{
	return _textAlignment;
}

- (void)setTextAlignment:(NSTextAlignment)newTextAlignment
{
	_textAlignment = newTextAlignment;
	NSMutableParagraphStyle *newParagraphStyle;
	NSMutableDictionary *attributes;
	
	attributes = [[_text attributesAtIndex:0 effectiveRange:NULL] mutableCopy]; 
	
	newParagraphStyle = [[attributes objectForKey:NSParagraphStyleAttributeName] mutableCopy];
	
	if(!newParagraphStyle){
		newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
	} 
	[newParagraphStyle setAlignment:newTextAlignment];
	[attributes setObject:newParagraphStyle forKey:NSParagraphStyleAttributeName];
	
	[_text setAttributes:attributes range:NSMakeRange( 0, [_text length])];
	
	[attributes release];
	[newParagraphStyle release];
	
	[_shape strokeUpdated];
}


# pragma mark  Drawing the path

- (void)updateStrokeForPath:(NSBezierPath *)drawPath
{
	NSBezierPath *path = drawPath;
	
	if([_shape isKindOfClass:[DBPolyline class]]){
		if([path elementAtIndex:[path elementCount] -2] == NSClosePathBezierPathElement){ 

			path = [[NSBezierPath alloc] init];
			NSPoint point;
			
			[drawPath elementAtIndex:0 associatedPoints:&point];
			[path moveToPoint:point];
			
			int i;

			for( i = 1; i < [drawPath elementCount]-2; i++ )
			{
				[drawPath elementAtIndex:i associatedPoints:&point];
				[path lineToPoint:point];
			}

			[drawPath elementAtIndex:0 associatedPoints:&point];
			[path lineToPoint:point];
			[path closePath];			
		}
	}
	
	
	[_textPath release];
	
	if(_text && ![[_text string] isEqualTo:@""]){
		if(_flipText){
 			_textPath = [[path bezierPathByReversingPath] bezierPathWithTextOnPath:_text yOffset:_textOffset];
		}else{
			_textPath = [path bezierPathWithTextOnPath:_text yOffset:_textOffset];
		}
	}
	
	
	[_textPath retain];
	NSAffineTransform *at = [[NSAffineTransform alloc] init]; 
	[at translateXBy:-[_shape bounds].origin.x yBy:-[_shape bounds].origin.y];
	[_textPath transformUsingAffineTransform:at ];
	[at release];
	
	if([_shape isKindOfClass:[DBPolyline class]] && 
		[path elementAtIndex:[path elementCount] -2] == NSClosePathBezierPathElement){
			[path release];
	}
}   

- (void)strokePath:(NSBezierPath *)drawPath
{
	[NSGraphicsContext saveGraphicsState];

	if(_strokeMode != DBNoStrokeMode){
	
		NSBezierPath *path = [drawPath copy];
		NSColor *mainPathColor;
		NSBezierPath *startArrow, *endArrow;
	
		[path setLineWidth:_lineWidth];
		[path setLineJoinStyle:_lineJoinStyle];
		[path setLineCapStyle:_lineCapStyle];
	
		if(_strokeMode == DBColorStrokeMode)
			mainPathColor = _strokeColor;                  
		else if(_strokeMode == DBImagePatternStrokeMode)
			mainPathColor = [NSColor colorWithPatternImage:_patternImage];
    
		[mainPathColor set];
	 
		[path stroke];

		if(_showStartArrow){
			startArrow = [path startArrowWithType:_startArrowStyle options:DBDefaultArrowOptions()];
			if(!(_startArrowStyle == DBOpenArrowStyle || _startArrowStyle == DBPointYArrowStyle) && _fillStartArrow){
				[startArrow setLineWidth:_lineWidth];
				[_startArrowFillColor setFill];
				[startArrow fill];
			}
			if(_strokeStartArrow)
				[startArrow stroke];
		}
	
		if(_showEndArrow){ 
			endArrow = [path endArrowWithType:_endArrowStyle options:DBDefaultArrowOptions()];
		
			if(!(_endArrowStyle == DBOpenArrowStyle || _endArrowStyle == DBPointYArrowStyle) && _fillEndArrow){
				[endArrow setLineWidth:_lineWidth];
				[_endArrowFillColor setFill];
				[endArrow fill];
			}
			if(_strokeEndArrow){			
				[endArrow stroke];
			}                       
		}

		[path release];    
	}
	
	[NSGraphicsContext restoreGraphicsState];
	
	NSAffineTransform *at = [[NSAffineTransform alloc] init]; 
	[at translateXBy:[_shape bounds].origin.x yBy:[_shape bounds].origin.y];

	[NSGraphicsContext saveGraphicsState];
	[at concat];
	
	NSColor *textColor = [_text attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
	
	if(textColor){
		[textColor set];
	}else{           
		[_strokeColor set];
	}
	
	//NSLog(@"color attribute : %@", [_text attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL]);
	
	[_textPath fill];
	[NSGraphicsContext restoreGraphicsState];
	
	[at release];
}

@end
