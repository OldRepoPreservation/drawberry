//
//  DBPolyline+SVG.h
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h> 

#import "DBPolyline.h"

@interface DBPolyline (SVGAdditions)
- (NSString *)SVGString;
- (NSString *)SVGPathString;
@end
