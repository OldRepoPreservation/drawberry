//
//  NSImage+FrameworkImage.h
//  OpenHUD
//
//  Created by Andy Matuschak on 3/21/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// In a framework, +imageNamed: doesn't work the way it's supposed to because it just searches the host app's bundle.
// So we use this category to access resource images instead.

@interface NSImage (OHFrameworkImageAdditions)
//+ frameworkImageNamed:(NSString *)name;
@end
