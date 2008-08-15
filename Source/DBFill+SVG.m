//
//  DBFill+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBFill+SVG.h"
#import "NSColor+SVG.h"


@implementation DBFill (SVGAdditions)
- (id)initWithShape:(DBShape *)shape SVGAttributes:(NSDictionary *)attr
{
	
	self = [self initWithShape:shape];
	
	_fillMode = 0;
	                
	NSString *string, *fill;
	float alpha;
	fill = [attr objectForKey:@"fill"];
	
	if(fill && ![fill isEqualToString:@"none"]){
		string = [attr objectForKey:@"fill-opacity"];
		if(string){
			alpha = [string floatValue];
		}else{
			alpha = 1.0;
		}
		if([fill characterAtIndex:0] == '#'){
			fill = [fill substringFromIndex:1];
		}

		[self setFillColor:[[NSColor colorFromHexRGB:fill] colorWithAlphaComponent:alpha]];
		_fillMode = DBColorFillMode;
	}else{
		_fillMode = DBNoneFillMode;
	}            
	return self;
}

- (NSString *)SVGFillStyleString
{
	if(_fillMode == DBColorFillMode){
		return [NSString stringWithFormat:@"fill:%@;fill-opacity:%f;",[_fillColor hexRGBFromColor], [_fillColor alphaComponent]];
	}else{
		return @"fill:none;";
	}
}
@end
