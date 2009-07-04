//
//  DBShape+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBShape+SVG.h"
#import "DBStroke+SVG.h"
#import "DBFill+SVG.h"

NSPoint DBPointWithString(NSString *pString)
{
	return NSPointFromString([NSString stringWithFormat:@"{%@}",pString]);
}


@implementation DBShape (SVGAdditions)
- (id)initWithSVGAttributes:(NSDictionary *)attr
{
	self = [self init];

	if(![attr objectForKey:@"stroke"] && ![attr objectForKey:@"stroke"]){
		_stroke = [[DBStroke alloc] initWithShape:self];

		DBFill *fill = [[DBFill alloc] initWithShape:self];
		[fill setFillMode:DBColorFillMode];
		[fill setFillColor:[NSColor blackColor]];
		[self addFill:fill];		
	}else{
		_stroke = [[DBStroke alloc] initWithShape:self SVGAttributes:attr];            
		
		DBFill *fill = [[DBFill alloc] initWithShape:self SVGAttributes:attr];
		if(fill){
			[self addFill:fill];		
		}		
	}
		
	_shadow = [[DBShadow alloc] initWithShape:self];

	return self;
}   

- (NSString *)SVGStyleString
{
	if([_fills count] > 0)
		return [NSString stringWithFormat:@"%@%@",[[_fills lastObject] SVGFillStyleString],[_stroke SVGStrokeStyleString]];
	else
		return [NSString stringWithFormat:@"fill:none;%@",[_stroke SVGStrokeStyleString]];
}              

- (NSString *)SVGString
{
	return nil;
}
@end
