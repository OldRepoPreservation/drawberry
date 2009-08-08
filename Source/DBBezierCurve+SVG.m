//
//  DBBezierCurve+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 05/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBBezierCurve+SVG.h"

#import "DBShape+SVG.h"

#import "DBSVGParser.h"
#import "DBSVGStringParser.h"

DBCurvePoint DBCurvePointWithString(NSString *pString)
{       
	NSArray*pStrings;
	DBCurvePoint cp;
	
	pStrings = [pString componentsSeparatedByString:@" "];
	cp.controlPoint1 = DBPointWithString([pStrings objectAtIndex:0]);
	cp.controlPoint2 = DBPointWithString([pStrings objectAtIndex:1]);
	cp.point = DBPointWithString([pStrings objectAtIndex:2]);
//	cp.hasControlPoints = NSEqualPoints(cp.controlPoint1,cp.controlPoint2) && NSEqualPoints(cp.controlPoint1,cp.point);
	cp.hasControlPoints = YES;
		
	return cp;
}

NSRange DBBetterRange(NSRange lRange,NSRange cRange)
{   
	NSRange range;
	
	if(lRange.location == NSNotFound){
	   	if(cRange.location == NSNotFound)
			range.location = NSNotFound;
		else
			range = cRange;
	}else if(cRange.location == NSNotFound){
			range = lRange;
	}else{
		range.location = MIN(cRange.location,lRange.location);
		range.length = 1;
	}
	
	return range;
}

@implementation DBBezierCurve (SVGAdditions)

- (id)initWithSVGAttributes:(NSDictionary *)attr
{
//	NSLog(@"new curve");
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
			[buffer appendString:[NSString stringWithFormat:@"C %f,%f %f,%f %f,%f ",_points[i-1].controlPoint1.x,_points[i-1].controlPoint1.y,
								  _points[i].controlPoint2.x,_points[i].controlPoint2.y,
								  _points[i].point.x,_points[i].point.y]];
			
			if(_points[i].closePath){
				[buffer appendString:[NSString stringWithFormat:@"C %f,%f %f,%f %f,%f ",_points[_pointCount-1].controlPoint1.x,_points[_pointCount-1].controlPoint1.y,
									  _points[beginningPoint].controlPoint2.x,_points[beginningPoint].controlPoint2.y,
									  _points[beginningPoint].point.x,_points[beginningPoint].point.y]];
				
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
- (void)addCurvePoint:(DBCurvePoint)cp
{
	_pointCount++;
	_points = realloc(_points, _pointCount*sizeof(DBCurvePoint));
	
	_points[_pointCount-1]=cp;
	
	_points[_pointCount-1].subPathStart = NO;
	_points[_pointCount-1].closePath = NO;

}

- (void)SVGMoveTo:(NSPoint)p
{
//	NSLog(@"moveTo:");
	[self addCurvePoint:DBMakeCurvePoint(p)];
	_points[_pointCount-1].subPathStart = YES;
}

- (void)SVGLineTo:(NSPoint)p
{
//	NSLog(@"lineTo:");
	[self addCurvePoint:DBMakeCurvePoint(p)];
}

- (void)SVGCurveToPoint:(NSPoint)aPoint controlPoint1:(NSPoint)controlPoint1 controlPoint2:(NSPoint)controlPoint2
{
//	NSLog(@"curveTo:");
	DBCurvePoint cp;
	cp.point = aPoint;
	cp.controlPoint1 = controlPoint1;
	cp.controlPoint2 = controlPoint2;
	
	[self addCurvePoint:cp];

	_points[_pointCount-2].controlPoint1 = controlPoint1;
	_points[_pointCount-1].controlPoint1 = aPoint;			
}

- (void)SVGClosePath
{
//	_points[_pointCount-1].closePath = YES;
	
	int subPathStart;
	
	subPathStart = DBSubPathBegging(_points,_pointCount);
	
	if(NSEqualPoints(_points[subPathStart].point, _points[_pointCount-1].point)){
		_points[subPathStart].controlPoint2 = _points[_pointCount-1].controlPoint2;
		_points = (DBCurvePoint *)removeCurvePointAtIndex(_pointCount-1,_points,_pointCount);
		_pointCount--;
		_points[_pointCount-1].closePath = YES;
	}

	_lineIsClosed = YES;
}

@end