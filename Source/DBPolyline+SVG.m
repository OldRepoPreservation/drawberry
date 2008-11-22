//
//  DBPolyline+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBPolyline+SVG.h"
#import "DBShape+SVG.h"

@implementation DBPolyline (SVGAdditions)
- (id)initWithSVGAttributes:(NSDictionary *)attr
{
	self = [super initWithSVGAttributes:attr];
	            
	NSMutableString *pathBuffer;
	NSString *substring;
	NSRange range, secRange;
	
	pathBuffer = [[attr objectForKey:@"d"] mutableCopy];
	
	if(![[pathBuffer substringWithRange:NSMakeRange(0,1)] isEqualTo:@"M"] && ![[pathBuffer substringWithRange:NSMakeRange(0,1)] isEqualTo:@"m"]){
		NSLog(@"Error in parsing SVG file : No introduction move to instruction");
		[self dealloc];
		return nil;
	}              
	
	range = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];
	
	if(range.location == NSNotFound){
		NSLog(@"Error in parsing SVG file : No more instruction than the move to instruction");
		[self dealloc];
		return nil;		
	}
	
//	secRange = [pathBuffer rangeOfString:@"M" options: NSCaseInsensitiveSearch];
	
//	range = NSMakeRange(secRange.location+secRange.length, range.location-(secRange.location+secRange.length)) ;
//	substring = [pathBuffer substringWithRange:range];
	
	_points = malloc(sizeof(NSPoint));
//    _points[0] = DBPointWithString(substring);
//    _pointCount = 1;	
	
//	[pathBuffer deleteCharactersInRange:range];
	
	range = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];
	
	while([pathBuffer length] > 0 && range.location != NSNotFound){
		substring = [pathBuffer substringWithRange:NSMakeRange(1,range.location-1)];

		_pointCount ++;
		_points = realloc(_points,_pointCount*sizeof(NSPoint));
		_points[_pointCount-1] = DBPointWithString(substring);

		[pathBuffer deleteCharactersInRange:NSMakeRange(0,range.location+1)];
		range = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];	
	}
	
	range = [pathBuffer rangeOfString:@"z" options: NSCaseInsensitiveSearch];
	if(range.location != NSNotFound){
		substring = [pathBuffer substringWithRange:NSMakeRange(1,range.location-1)];
		_lineIsClosed = YES;
	}else{
		substring = pathBuffer;
	}

	_pointCount ++;
	_points = realloc(_points,_pointCount*sizeof(NSPoint));
	_points[_pointCount-1] = DBPointWithString(substring);
	
	return self;
}

- (NSString *)SVGPathString
{
	NSMutableString *buffer;
	
	buffer = [[NSMutableString alloc] init];
	                            
	[buffer appendString:[NSString stringWithFormat:@"M %f,%f ",_points[0].x,_points[0].y]];
	
	int i;

	for( i = 1; i < _pointCount; i++ )
	{
		[buffer appendString:[NSString stringWithFormat:@"L %f,%f ",_points[i].x,_points[i].y]];
	}                                                                                    
	
	if(_lineIsClosed){
		[buffer appendString:@" z"];
	}
	
	return [buffer autorelease];
}

- (NSString *)SVGString
{
	return [NSString stringWithFormat:@"<path  style=\"%@\" \n d=\"%@\"  />\n",[self SVGStyleString],[self SVGPathString]];
}
@end 


