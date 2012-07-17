//
//  NSColor+SVG.m
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//
/*
	NSColor: Instantiate from Web-like Hex RRGGBB string
	Original Source: <http://cocoa.karelia.com/Foundation_Categories/NSColor__Instantiat.m>
	(See copyright notice at <http://cocoa.karelia.com>)
*/

#import "NSColor+SVG.h"

NSString * DBHexStringFromInt(int input)
{
	int a,b;
	char aChar ='0', bChar='0';
	
	a = input%16;
	b = ((int) input/16) %16;
	
	switch (a) {
		case 15 : aChar = 'f'; break;
		case 14 : aChar = 'e'; break;
		case 13 : aChar = 'd'; break;
		case 12 : aChar = 'c'; break;
		case 11 : aChar = 'b'; break;
		case 10 : aChar = 'a'; break;

		case 9 : aChar = '9'; break;
		case 8 : aChar = '8'; break;
		case 7 : aChar = '7'; break;
		case 6 : aChar = '6'; break;
		case 5 : aChar = '5'; break;
		case 4 : aChar = '4'; break;
		case 3 : aChar = '3'; break;
		case 2 : aChar = '2'; break;
		case 1 : aChar = '1'; break;
		case 0 : aChar = '0'; break;
   	}
	
	switch (b) {
		case 15 : bChar = 'f'; break;
		case 14 : bChar = 'e'; break;
		case 13 : bChar = 'd'; break;
		case 12 : bChar = 'c'; break;
		case 11 : bChar = 'b'; break;
		case 10 : bChar = 'a'; break;
		
		case 9 : bChar = '9'; break;
		case 8 : bChar = '8'; break;
		case 7 : bChar = '7'; break;
		case 6 : bChar = '6'; break;
		case 5 : bChar = '5'; break;
		case 4 : bChar = '4'; break;
		case 3 : bChar = '3'; break;
		case 2 : bChar = '2'; break;
		case 1 : bChar = '1'; break;
		case 0 : bChar = '0'; break;
	}
	
	return [NSString stringWithFormat:@"%c%c",bChar,aChar];
}    

@implementation NSColor (SVGAdditions)


+ (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{ 
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
		colorWithCalibratedRed:		(float)redByte	/ 0xff
							green:	(float)greenByte/ 0xff
							blue:	(float)blueByte	/ 0xff
							alpha:1.0];
							
	return result;
}

- (NSString *)hexRGBFromColor
{
	// float red,green, blue;
	// 
	// [[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:NULL];
	// 
	// return [NSString stringWithFormat:@"#%@%@%@",DBHexStringFromInt(floorf(blue*256)),DBHexStringFromInt(floorf(green*256)),DBHexStringFromInt(floorf(red*256))]; 
	
	  float redFloatValue, greenFloatValue, blueFloatValue;
	  int redIntValue, greenIntValue, blueIntValue;
	  NSString *redHexValue, *greenHexValue, *blueHexValue;

	  //Convert the NSColor to the RGB color space before we can access its components
	  NSColor *convertedColor=[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

	  if(convertedColor)
	  {
	    // Get the red, green, and blue components of the color
	    [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];

	    // Convert the components to numbers (unsigned decimal integer) between 0 and 255
	    redIntValue=redFloatValue*255.99999f;
	    greenIntValue=greenFloatValue*255.99999f;
	    blueIntValue=blueFloatValue*255.99999f;

	    // Convert the numbers to hex strings
	    redHexValue=[NSString stringWithFormat:@"%02x", redIntValue];
	    greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
	    blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];

	    // Concatenate the red, green, and blue components' hex strings together with a "#"
	    return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
	  }
	  return nil;
	
}
@end
