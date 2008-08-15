//
//  DBRectangle+SVG.h
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBRectangle.h"

@interface DBRectangle (SVGAdditions) 

- (id)initWithSVGAttributes:(NSDictionary *)attr;

@end
