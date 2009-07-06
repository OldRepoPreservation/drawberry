//
//  DBOval+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 06/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBOval+SVG.h"
#import "DBShape+SVG.h"
#import "DBPolyline+SVG.h"


@implementation DBOval (SVGAdditions)
- (NSString *)SVGString
{
	NSString *pathString;
	
	pathString = [(DBPolyline *)[self convert] SVGPathString];
	
	return [NSString stringWithFormat:@"<path  style=\"%@\" \n d=\"%@\"  />\n",[self SVGStyleString],pathString];
}
@end
