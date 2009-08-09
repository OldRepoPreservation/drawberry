//
//  DBOval+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 06/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBOval+SVG.h"
#import "DBShape+SVG.h"
#import "DBBezierCurve+SVG.h"

@implementation DBOval (SVGAdditions)
- (NSString *)SVGString
{
	NSString *pathString;
	
	pathString = [[self convertToBezierCurve] SVGPathString];
	
	return [NSString stringWithFormat:@"<path  style=\"%@\" \n d=\"%@\"  />\n",[self SVGStyleString],pathString];
}
@end
