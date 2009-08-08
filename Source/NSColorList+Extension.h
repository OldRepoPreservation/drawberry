//
//  NSColorList+Extension.h
//  DBColorSwatchApp
//
//  Created by Raphael Bost on 08/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColorList (DBExtension)
- (id)initWithList:(NSColorList *)list name:(NSString *)name;
- (NSString *)keyWithColor:(NSColor *)color;
@end

@interface NSColor (DBExtension)
- (NSString *)littleDescription;
@end
