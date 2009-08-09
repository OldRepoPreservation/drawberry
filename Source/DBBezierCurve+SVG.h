//
//  DBBezierCurve+SVG.h
//  DrawBerry
//
//  Created by Raphael Bost on 05/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBBezierCurve.h"

@interface DBBezierCurve (SVGAdditions)
- (NSString *)SVGPathString;
@end
