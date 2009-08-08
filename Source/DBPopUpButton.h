//
//  DBPopUpButton.h
//  DrawBerry
//
//  Created by Raphael Bost on 07/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBPopUpButton : NSPopUpButton {
	NSImage *_image;
}
- (NSImage *)image;
- (void)setImage:(NSImage *)aImage;
@end
