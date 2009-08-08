//
//  DBStroke+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBStroke+SVG.h"
#import "NSColor+SVG.h"


@implementation DBStroke (SVGAdditions)
- (id)initWithShape:(DBShape *)shape SVGAttributes:(NSDictionary *)attr
{
	
	self = [self initWithShape:shape];
	
	_strokeMode = 2;
	                
	NSString *string, *stroke;
	float alpha;
	stroke = [attr objectForKey:@"stroke"];
	
	if(stroke  && ![stroke isEqualToString:@"none"]){
		string = [attr objectForKey:@"stroke-opacity"];
		if(string){
			alpha = [string floatValue];
		}else{
			alpha = 1.0;
		}
		if([stroke characterAtIndex:0] == '#'){
			stroke = [stroke substringFromIndex:1];
		}
		
		[self setStrokeColor:[[NSColor colorFromHexRGB:stroke] colorWithAlphaComponent:alpha]];
	   	_strokeMode = DBColorStrokeMode;
	}else{
		_strokeMode = DBNoStrokeMode;
	}            
	return self;
}                                   

- (NSString *)SVGStrokeStyleString
{                      
	NSString *strokeStyle;
   	if(_strokeMode == DBColorStrokeMode){
		NSString *capStyle, *joinStyle;
		
		switch (_lineJoinStyle){
			case NSMiterLineJoinStyle : joinStyle = @"miter"; break;
			case NSRoundLineJoinStyle : joinStyle = @"round"; break;
			case NSBevelLineJoinStyle : joinStyle = @"bevel"; break;
		}

		switch (_lineCapStyle){
			case NSButtLineCapStyle : capStyle = @"butt"; break;
			case NSSquareLineCapStyle : capStyle = @"round"; break;
			case NSRoundLineCapStyle : capStyle = @"square"; break;
		}

		strokeStyle = [NSString stringWithFormat:@"stroke:%@;stroke-width:%fpx;stroke-opacity:%f;stroke-linecap:%@;stroke-linejoin:%@;",[_strokeColor hexRGBFromColor], _lineWidth, [_strokeColor alphaComponent],capStyle,joinStyle];
	}else strokeStyle = @"stroke:none;";
	
	return strokeStyle;
}
@end
