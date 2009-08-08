//
//  DBShape+SVG.h
//  DBSVGReader
//
//  Created by Raphael Bost on 21/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBShape.h"
#import "DBShadow.h"
#import "DBStroke.h"
#import "DBFill.h"

//@interface DBShape {
//	DBFill *_fill;
//	DBStroke *_stroke;
//	DBShadow *_shadow;
//}
@interface DBShape (SVGAdditions)
- (id)initWithSVGAttributes:(NSDictionary *)attr;
- (NSString *)SVGString;
- (NSString *)SVGStyleString;
@end

NSPoint DBPointWithString(NSString *pString);