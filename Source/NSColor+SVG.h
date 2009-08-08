//
//  NSColor+SVG.h
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (SVGAdditions)
+ (NSColor *) colorFromHexRGB:(NSString *) inColorString;
- (NSString *)hexRGBFromColor;
@end
