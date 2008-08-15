//
//  DBCIFilterPoint.m
//  DrawBerry
//
//  Created by Raphael Bost on 27/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBCIFilterPoint.h"

const CIFilterPoint CIZeroFilterPoint = {nil,nil};

CIFilterPoint CIFilterPointWithCIFilter(CIFilter *filter, NSString *key)
{
	CIFilterPoint cifp;
	cifp.filter = filter;
	cifp.key = key;
	
	return cifp;
}

NSPoint DBPointForCIFilterPoint(CIFilterPoint ciPoint)
{
	CIVector *v = [ciPoint.filter valueForKey:ciPoint.key];
	
// 	NSDictionary *parameter = [[ciPoint.filter attributes] objectForKey:ciPoint.key];	
//	if([[parameter objectForKey:kCIAttributeClass] isEqualToString:@"NSAffineTransform"]){
		
   	if([v isKindOfClass:[NSAffineTransform class]]){
		NSAffineTransformStruct ts = [(NSAffineTransform *)v transformStruct];
		
		return NSMakePoint(ts.tX, ts.tY);
	}
	return NSMakePoint([v X], [v Y]);
}

CIVector * DBVectorForCIFilterPoint(CIFilterPoint ciPoint)
{
	return [ciPoint.filter valueForKey:ciPoint.key];
} 

void DBSetCIFilterPoint(CIFilterPoint ciPoint, NSPoint point)
{
	id value = [ciPoint.filter valueForKey:ciPoint.key];
	
	if([value isKindOfClass:[NSAffineTransform class]]){
   		NSAffineTransformStruct ts = [(NSAffineTransform *)value transformStruct];
	    
		ts.tX = point.x;
		ts.tY = point.y;
		
		[value setTransformStruct:ts];
		[ciPoint.filter setValue:value forKey:ciPoint.key];            
	}else{
	CIVector *v = [[CIVector alloc] initWithX:point.x Y:point.y Z:[value Z]];
	[ciPoint.filter setValue:v	forKey:ciPoint.key];
	[v release];
	}
}