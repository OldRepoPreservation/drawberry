//
//  DBSVGStringParser.m
//  DrawBerry
//
//  Created by Raphael Bost on 01/06/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import "DBSVGStringParser.h"

#include "rsvg-path.h"

void lineTo(void * sender, float x, float y)
{
	[(DBSVGStringParser *)sender lineTo:NSMakePoint(x, y)];
}

void moveTo(void * sender, float x, float y)
{
	[(DBSVGStringParser *)sender moveTo:NSMakePoint(x, y)];
}

void curveTo(void * sender, float x1, float y1, float x2, float y2, float x3, float y3)
{
	[(DBSVGStringParser *)sender curveToPoint:NSMakePoint(x3,y3) controlPoint1:NSMakePoint(x1,y1) controlPoint2:NSMakePoint(x2,y2)];
}

void closePath(void * sender)
{
	[(DBSVGStringParser *)sender closePath];
}
@implementation DBSVGStringParser
- (id)initWithOwner:(id)o
{
	self = [super init];
	
	owner = o;
	
	return self;
}

- (void)parseString:(NSString *)s
{
	rsvg_set_moveTo_callback(moveTo);
	rsvg_set_lineTo_callback(lineTo);
	rsvg_set_curveTo_callback(curveTo);
	rsvg_set_close_callback(closePath);
	
	rsvg_parse_path([s UTF8String],self);
}

- (void)lineTo:(NSPoint)p
{
	if([owner respondsToSelector:@selector(SVGLineTo:)]){
		[owner SVGLineTo:p];
	}
}

- (void)moveTo:(NSPoint)p
{
	if([owner respondsToSelector:@selector(SVGMoveTo:)]){
		[owner SVGMoveTo:p];
	}
}

- (void)curveToPoint:(NSPoint)aPoint controlPoint1:(NSPoint)controlPoint1 controlPoint2:(NSPoint)controlPoint2
{
	if([owner respondsToSelector:@selector(SVGCurveToPoint:controlPoint1:controlPoint2:)]){
		[owner SVGCurveToPoint:aPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
	}
}

- (void)closePath
{
	if([owner respondsToSelector:@selector(SVGClosePath)]){
		[owner SVGClosePath];
	}
}
@end
