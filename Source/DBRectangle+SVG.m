//
//  DBRectangle+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBRectangle+SVG.h"
#import "DBShape+SVG.h"
#import "DBPolyline+SVG.h"


@implementation DBRectangle (SVGAdditions)

- (id)initWithSVGAttributes:(NSDictionary *)attr
{
	self = [super initWithSVGAttributes:attr];
	            
	NSRect rect;
	NSString *string;
	
	string = [attr objectForKey:@"x"];
	rect.origin.x = [string floatValue];
	string = [attr objectForKey:@"y"];
	rect.origin.y = [string floatValue];
	string = [attr objectForKey:@"width"];
	rect.size.width = [string floatValue];
	string = [attr objectForKey:@"height"];
	rect.size.height = [string floatValue];
	
	_point1 = rect.origin;
	_point2 = rect.origin;
	_point3 = rect.origin;
	_point4 = rect.origin;
	
	_point2.x += rect.size.width;
	_point4.y += rect.size.height;
	_point3.x += rect.size.width;
	_point3.y += rect.size.height;
	
	_radiusKnob = _point2;
	
	return self;
}

- (NSString *)SVGString
{
	NSString *pathString;
	
	pathString = [[self convertToBezierCurve] SVGPathString];
	
	return [NSString stringWithFormat:@"<path  style=\"%@\" \n d=\"%@\"  />\n",[self SVGStyleString],pathString];
}
@end
