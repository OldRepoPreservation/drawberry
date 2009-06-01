//
//  DBPolyline+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBPolyline+SVG.h"
#import "DBShape+SVG.h"

#import "DBSVGStringParser.h"


@implementation DBPolyline (SVGAdditions)
- (id)initWithSVGAttributes:(NSDictionary *)attr
{
	self = [super initWithSVGAttributes:attr];
	
	DBSVGStringParser *stringParser;
	
	stringParser = [[DBSVGStringParser alloc] initWithOwner:self];
	
	[stringParser parseString:[attr objectForKey:@"d"]];
	
	[stringParser release];
	
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

#pragma mark Callbacks
- (void)addPoint:(NSPoint)p
{
	_pointCount++;
	_points = realloc(_points, _pointCount*sizeof(NSPoint));
	
	_points[_pointCount-1]=p;
}

- (void)SVGMoveTo:(NSPoint)p
{
	[self addPoint:p];
}

- (void)SVGLineTo:(NSPoint)p
{
	[self addPoint:p];
}

- (void)SVGClosePath
{
	_lineIsClosed = YES;
}

@end 


