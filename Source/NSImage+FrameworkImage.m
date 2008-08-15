//
//  NSImage+FrameworkImage.m
//  OpenHUD
//
//  Created by Andy Matuschak on 3/21/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "NSImage+FrameworkImage.h"

// Used for a slight hack in the method below to make sure we get the correct bundle for this file.
@interface OHDummyClass : NSObject
@end
@implementation OHDummyClass
@end

@implementation NSImage (OHFrameworkImage)

// See the header for info on why this is here.
/*
+ frameworkImageNamed:(NSString *)name
{
	if ([NSImage imageNamed:name]) { return [NSImage imageNamed:name]; }
	NSBundle *frameworkBundle = [NSBundle bundleForClass:[OHDummyClass class]];
	NSString *imagePath = [frameworkBundle pathForImageResource:name];
	if (!imagePath) { return nil; }
	NSImage *myImage = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
	[myImage setName:name];
	return myImage;
}
*/
@end
