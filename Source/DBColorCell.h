//
//  DBColorCell.h
//  DBColorSwatchApp
//
//  Created by Raphael Bost on 08/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBColorCell : NSCell {
	NSColor *_color;
}                
- (NSColor *)color;
- (void)setColor:(NSColor *)aColor;

@end
