//
//  DBPolylineTransformation.h
//  Poly2Curve
//
//  Created by Raphael Bost on 20/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (DBPolylineTransformation)
+ (NSBezierPath *)transformPointsToCurve:(NSPoint *)points count:(unsigned int)pCount precision:(float)precision;
@end
