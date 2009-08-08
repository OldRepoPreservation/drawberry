//
//  DBFill+SVG.h
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBFill.h"


@interface DBFill (SVGAdditions) 
- (id)initWithShape:(DBShape *)shape SVGAttributes:(NSDictionary *)attr;
- (NSString *)SVGFillStyleString;
@end
