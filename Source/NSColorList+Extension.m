//
//  NSColorList+Extension.m
//  DBColorSwatchApp
//
//  Created by Raphael Bost on 08/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSColorList+Extension.h"


@implementation NSColorList (DBExtension)
- (id)initWithList:(NSColorList *)list name:(NSString *)name
{
	self = [self initWithName:name];
	             
	if(self)
	{
		NSEnumerator *e = [[list allKeys] objectEnumerator];
		NSString * key;

		while((key = [e nextObject])){
			[self setColor:[list colorWithKey:key] forKey:key] ;
		}            
	}
	return self;
}

- (NSString *)keyWithColor:(NSColor *)color
{        
	if(!color){
		return nil;
	}              
	
	NSEnumerator *e = [[self allKeys] reverseObjectEnumerator];
	NSString * key;

	while((key = [e nextObject])){
		if([[self colorWithKey:key] isEqualTo:color]){
			break;
		}
	}             
	return key;
} 
@end

@implementation NSColor (DBExtension)
- (NSString *)littleDescription
{
	NSString *clrSpace;
	clrSpace = [self colorSpaceName];
	
	if([clrSpace isEqualTo:NSCalibratedWhiteColorSpace] || [clrSpace isEqualTo:NSDeviceWhiteColorSpace]
		|| [clrSpace isEqualTo:NSCalibratedBlackColorSpace] || [clrSpace isEqualTo:NSDeviceBlackColorSpace]){
		return [NSString stringWithFormat:@"White %f",[self whiteComponent]];
	}else if([clrSpace isEqualTo:NSCalibratedRGBColorSpace] || [clrSpace isEqualTo:NSDeviceRGBColorSpace]){
		return [NSString stringWithFormat:@"Red %f Green %f Blue %f",[self redComponent],[self greenComponent],[self blueComponent]];
	}else if([clrSpace isEqualTo:NSDeviceCMYKColorSpace]){
		return [NSString stringWithFormat:@"Cyan %f Mag. %f Yellow %f Black %f",[self cyanComponent],[self magentaComponent],[self yellowComponent],[self blackComponent]];
	}
	return @"Color";
}
@end