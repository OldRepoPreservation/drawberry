//
//  DBCIFilterPoint.h
//  DrawBerry
//
//  Created by Raphael Bost on 27/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

  
typedef struct _CIFilterPoint
{
	CIFilter *filter;
	NSString *key;
}CIFilterPoint ;

extern const CIFilterPoint CIZeroFilterPoint;

CIFilterPoint CIFilterPointWithCIFilter(CIFilter *filter, NSString *key);
NSPoint DBPointForCIFilterPoint(CIFilterPoint ciPoint);                 
CIVector * DBVectorForCIFilterPoint(CIFilterPoint ciPoint);
void DBSetCIFilterPoint(CIFilterPoint ciPoint, NSPoint point);
