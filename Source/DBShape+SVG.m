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

	_stroke = [[DBStroke alloc] initWithShape:self SVGAttributes:attr];            
	_fill = [[DBFill alloc] initWithShape:self SVGAttributes:attr];            
	_shadow = [[DBShadow alloc] initWithShape:self];

	return self;
}   

- (NSString *)SVGStyleString
{
	return [NSString stringWithFormat:@"%@%@",[_fill SVGFillStyleString],[_stroke SVGStrokeStyleString]];
}              

- (NSString *)SVGString
{
	return nil;
}
@end
