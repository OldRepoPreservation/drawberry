//
//  DBStroke+SVG.h
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBStroke.h"

@interface DBStroke (SVGAdditions) 
- (id)initWithShape:(DBShape *)shape SVGAttributes:(NSDictionary *)attr;
- (NSString *)SVGStrokeStyleString;
@end
