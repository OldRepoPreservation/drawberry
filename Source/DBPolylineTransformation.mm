//
//  DBPolylineTransformation.m
//  Poly2Curve
//
//  Created by Raphael Bost on 20/07/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import "DBPolylineTransformation.h"

#include "vectorisation.h"

@interface NSBezierPath	(Moult)
- (id)initWithMoult:(Moult *)moult;
+ (id)bezierPathWithMoult:(Moult *)m;
@end


nE* point2nE(NSPoint *points, unsigned int pCount){
	
	if(pCount <= 0) return NULL;
	
	nE* start, *end,*ne;
	
	start = nE::newnE();
	start->prev = NULL;
	start->next = NULL;
	start->p = points[0];
	end = start;
	
	int i;
	
	for (i = 1; i < pCount; i++) {
		ne = nE::newnE();
		ne->prev = end;
		ne->next = NULL;
		end->next = ne;
		end = ne;
		end->p = points[i];
	}
	
	return start;
}

NSBezierPath * transform(NSPoint *points,unsigned int pCount,float precision)
{
	nE* pList;
	Moult *result;
	NSBezierPath *path;
	
	result =new Moult;

	pList = point2nE(points, pCount); // transform points into a list
	
//	lisse(pList,precision);

	vectoriz(pList, result, precision); // vectorize
	
	path = [NSBezierPath bezierPathWithMoult:result]; // transform moult into path
	
	// cleanup
	pList->supNexts();
	
	foreach(point,pp,result) {
		delete pp;
	}
	result->supall();
	
	return path;
}

@implementation NSBezierPath (Moult)

- (id)initWithMoult:(Moult *)moult 
{
	self = [self init];
	
	if (moult->count > 0) {
		Enum<point> e(moult);
		point * p=e.next(),*c1,*c2;
		
		[self moveToPoint:*p];
		
		while (1) {
			c1= e.next();
			if(c1 == NULL) break; 
			c2= e.next();
			p=e.next();
			[self curveToPoint:*p controlPoint1:*c1 controlPoint2:*c2];			
		}
	}
	return self;
}

+ (id)bezierPathWithMoult:(Moult *)m
{
	return [[[NSBezierPath alloc] initWithMoult:m] autorelease];
}
@end

@implementation NSBezierPath (DBPolylineTransformation)

+ (NSBezierPath *)transformPointsToCurve:(NSPoint *)points count:(unsigned int)pCount precision:(float)precision
{
	return transform(points, pCount, precision);
}
@end