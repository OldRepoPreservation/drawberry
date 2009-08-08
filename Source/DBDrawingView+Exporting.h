//
//  DBDrawingView+Exporting.h
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBDrawingView.h"

@interface DBDrawingView (Exporting)
- (NSData *)dataWithFormat:(NSString *)format jpegCompression:(float)compressionFactor;
- (NSData *)dataWithTIFFInsideRect:(NSRect)rect;
- (NSData *)dataWithPNGInsideRect:(NSRect)rect;
- (NSData *)dataWithJPEGInsideRect:(NSRect)rect compressionFactor:(float)quality;
- (NSData *)dataWithPSDInsideRect:(NSRect)rect;
- (NSData *)dataWithAIInsideRect:(NSRect)rect;
@end
