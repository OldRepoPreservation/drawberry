//
//  DBBezierCurve+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 05/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBBezierCurve+SVG.h"

#import "DBShape+SVG.h"

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
	self = [super initWithSVGAttributes:attr];
	            
	NSMutableString *pathBuffer;
	NSString *substring;
	NSRange range, lRange, cRange;
	BOOL _isLine;
	
	pathBuffer = [[attr objectForKey:@"d"] mutableCopy];
	
	if(![[pathBuffer substringWithRange:NSMakeRange(0,1)] isEqualTo:@"M"] && ![[pathBuffer substringWithRange:NSMakeRange(0,1)] isEqualTo:@"m"]){
		NSLog(@"Error in parsing SVG file : No introduction move to instruction");
		[self dealloc];
		return nil;
	}              
	
	lRange = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];
    cRange = [pathBuffer rangeOfString:@"c" options: NSCaseInsensitiveSearch];
	
	if(lRange.location == NSNotFound && cRange.location == NSNotFound){
		NSLog(@"Error in parsing SVG file : No more instruction than the move to instruction");
		[self dealloc];
		return nil;		
	}
	
//	secRange = [pathBuffer rangeOfString:@"M" options: NSCaseInsensitiveSearch];
	
//	range = NSMakeRange(secRange.location+secRange.length, range.location-(secRange.location+secRange.length)) ;
//	substring = [pathBuffer substringWithRange:range];
	
	_points = malloc(sizeof(DBCurvePoint));
//    _points[0] = DBPointWithString(substring);
//    _pointCount = 1;	
	
//	[pathBuffer deleteCharactersInRange:range];
	
	lRange = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];
    cRange = [pathBuffer rangeOfString:@"c" options: NSCaseInsensitiveSearch];
   	
	range = DBBetterRange(lRange,cRange);
	
	if([[pathBuffer substringWithRange:range] isEqualToString:@"l"]){
		_isLine = YES;
	}else{
		_isLine = NO;
	}
	
	// skip the M character
	
	substring = [pathBuffer substringWithRange:NSMakeRange(1,range.location-1)];
	_pointCount ++;
	_points[_pointCount-1] = DBMakeCurvePoint( DBPointWithString(substring) );			
	[pathBuffer deleteCharactersInRange:NSMakeRange(0,range.location+1)];
	
	//
	
	lRange = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];
    cRange = [pathBuffer rangeOfString:@"c" options: NSCaseInsensitiveSearch];
   	
	range = DBBetterRange(lRange,cRange);

	while([pathBuffer length] > 0 && range.location != NSNotFound){
		substring = [pathBuffer substringWithRange:NSMakeRange(1,range.location-1)];

		_pointCount ++;
		_points = realloc(_points,_pointCount*sizeof(DBCurvePoint));
		
		if(_isLine){
			_points[_pointCount-1] = DBMakeCurvePoint( DBPointWithString(substring) );			
			_points[_pointCount-2].controlPoint1 =  _points[_pointCount-1].controlPoint1;			
		}else{
			_points[_pointCount-1] = DBCurvePointWithString(substring);
			_points[_pointCount-2].controlPoint1 =  _points[_pointCount-1].controlPoint1;			
		}

		[pathBuffer deleteCharactersInRange:NSMakeRange(0,range.location+1)];
		lRange = [pathBuffer rangeOfString:@"l" options: NSCaseInsensitiveSearch];
		cRange = [pathBuffer rangeOfString:@"c" options: NSCaseInsensitiveSearch];
		
		range = DBBetterRange(lRange,cRange);

		if(range.location != NSNotFound && [[pathBuffer substringWithRange:range] isEqualToString:@"l"]){
			_isLine = YES;
		}else{
			_isLine = NO;
		}
	}
	
	range = [pathBuffer rangeOfString:@"z" options: NSCaseInsensitiveSearch];
	if(range.location != NSNotFound){
		substring = [pathBuffer substringWithRange:NSMakeRange(1,range.location-1)];
		_lineIsClosed = YES;
	}else{
		substring = pathBuffer;
	}
    
	DBCurvePoint tmpPoint;
	if(_isLine){
    	tmpPoint = DBMakeCurvePoint( DBPointWithString(substring) );
	}else{
		tmpPoint = DBCurvePointWithString(substring);
	}	
		
	if(!NSEqualPoints(_points[0].point, tmpPoint.point)){
		_pointCount ++;
		_points = realloc(_points,_pointCount*sizeof(DBCurvePoint));
		_points[_pointCount-1] = tmpPoint;
	   	_points[_pointCount-2].controlPoint1 = _points[_pointCount-1].controlPoint1;					
	}else {
		_points[_pointCount-1].controlPoint1 = tmpPoint.controlPoint1;
	}

//   	_points[_pointCount-1].controlPoint1 =  _points[0].controlPoint1;			
	
	
	return self;
}

- (NSString *)SVGPathString
{
	NSMutableString *buffer;
	
	buffer = [[NSMutableString alloc] init];
	                            
	[buffer appendString:[NSString stringWithFormat:@"M %f,%f ",_points[0].point.x,_points[0].point.y]];
	
	int i;

	for( i = 1; i < _pointCount; i++ )
	{
		[buffer appendString:[NSString stringWithFormat:@"C %f,%f %f,%f %f,%f ",_points[i-1].controlPoint1.x,_points[i-1].controlPoint1.y,
																   _points[i].controlPoint2.x,_points[i].controlPoint2.y,
																   _points[i].point.x,_points[i].point.y]];
	}                                                                                    
	
	if(_lineIsClosed){
		[buffer appendString:[NSString stringWithFormat:@"C %f,%f %f,%f %f,%f ",_points[_pointCount-1].controlPoint1.x,_points[_pointCount-1].controlPoint1.y,
																   _points[0].controlPoint2.x,_points[0].controlPoint2.y,
																   _points[0].point.x,_points[0].point.y]];
		[buffer appendString:@" z"];
	}
	
	return [buffer autorelease];
}

- (NSString *)SVGString
{
	return [NSString stringWithFormat:@"<path  style=\"%@\" \n d=\"%@\"  />\n",[self SVGStyleString],[self SVGPathString]];
}
@end