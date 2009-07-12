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
	                            
	[buffer appendString:[NSString stringWithFormat:@"M %f,%f ",_points[0].point.x,_points[0].point.y]];
	
	int i, beginningPoint;

	beginningPoint = 0;

	for( i = 1; i < _pointCount; i++ )
	{
	
		if(_points[i].subPathStart){
			[buffer appendString:[NSString stringWithFormat:@"M %f,%f ",_points[i].point.x,_points[i].point.y]];
			beginningPoint = i;
		}else{
			[buffer appendString:[NSString stringWithFormat:@"L %f,%f ",_points[i].point.x,_points[i].point.y]];

			if(_points[i].closePath){
				[buffer appendString:[NSString stringWithFormat:@"L %f,%f ",_points[beginningPoint].point.x,_points[beginningPoint].point.y]];
				[buffer appendString:@" z"];
			}
		}
	}                                                                                    
	
	return [buffer autorelease];
}

- (NSString *)SVGString
{
	return [NSString stringWithFormat:@"<path  style=\"%@\" \n d=\"%@\"  />\n",[self SVGStyleString],[self SVGPathString]];
}

#pragma mark Callbacks
- (void)addPolyPoint:(NSPoint)p
{
	_pointCount++;
	_points = realloc(_points, _pointCount*sizeof(DBPolylinePoint));
	
	_points[_pointCount-1].point=p;
	_points[_pointCount-1].subPathStart = NO;
	_points[_pointCount-1].closePath = NO;

}

- (void)SVGMoveTo:(NSPoint)p
{
//	NSLog(@"move to %@",NSStringFromPoint(p));
	[self addPolyPoint:p];
	_points[_pointCount-1].subPathStart = YES;
}

- (void)SVGLineTo:(NSPoint)p
{
//	NSLog(@"line to %@",NSStringFromPoint(p));
	[self addPolyPoint:p];
}

- (void)SVGClosePath
{
	int subPathStart;
	
	subPathStart = DBSubPolyPathBegging(_points,_pointCount);
	
	if(NSEqualPoints(_points[subPathStart].point, _points[_pointCount-1].point)){
		_points = (DBPolylinePoint *)removePointAtIndex(_pointCount-1,_points,_pointCount);
		_pointCount--;
		_points[_pointCount-1].closePath = YES;
	}
	
	_lineIsClosed = YES;
}

@end 


