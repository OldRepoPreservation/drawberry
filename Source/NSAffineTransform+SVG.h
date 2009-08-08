//
//  NSAffineTransform+SVG.h
//  DrawBerry
//
//  Created by Raphael Bost on 12/06/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAffineTransform (SVGAdditions)
- (id)initWithSVGString:(NSString *)s;
@end
