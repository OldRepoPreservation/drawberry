//
//  NSAffineTransform+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 12/06/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSAffineTransform+SVG.h"

#import "NSString+Extensions.h"

@interface NSAffineTransform (SVGAdditions_Private)
- (void)_initTranslate:(NSString *)s;
- (void)_initRotate:(NSString *)s;
- (void)_initMatrix:(NSString *)s;
- (void)_initSkewX:(NSString *)s;
- (void)_initSkewY:(NSString *)s;
@end


@implementation  NSAffineTransform (SVGAdditions)
- (id)initWithSVGString:(NSString *)s
{
	self = [self init];
	
	NSArray *a;
	a = [s componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
	
	if([a count] < 1) return nil;
	
	if([[a objectAtIndex:0] rangeOfString:@"matrix"].location != NSNotFound){
		[self _initMatrix:[a objectAtIndex:1]];
	}else if ([[a objectAtIndex:0] rangeOfString:@"translate"].location != NSNotFound) {
		[self _initTranslate:[a objectAtIndex:1]];
	}else if ([[a objectAtIndex:0] rangeOfString:@"rotate"].location != NSNotFound) {
		[self _initRotate:[a objectAtIndex:1]];
	}else if ([[a objectAtIndex:0] rangeOfString:@"skewX"].location != NSNotFound) {
		[self _initSkewX:[a objectAtIndex:1]];
	}else if ([[a objectAtIndex:0] rangeOfString:@"skewY"].location != NSNotFound) {
		[self _initSkewY:[a objectAtIndex:1]];
	}
	
	return self;
}

- (void)_initTranslate:(NSString *)s
{
	float * coords;
	int count;
	
	coords = [s getFloats:&count];
	
	if(count == 1){
		[self translateXBy:coords[0] yBy:0.0];
	}else if (count == 2) {
		[self translateXBy:coords[0] yBy:coords[1]];
	}else {
		[NSException raise:@"DBInvalidArgumentException"
					format:@"String passed for initializing affine transform not valid (translate)"];
	}
}

- (void)_initRotate:(NSString *)s
{
	float * coords;
	int count;
	
	coords = [s getFloats:&count];
	
	if(count == 1){
		[self rotateByDegrees:coords[0]];
	}else if (count == 3) {
		[self translateXBy:coords[1] yBy:coords[2]];
		[self rotateByDegrees:coords[0]];
		[self translateXBy:-coords[1] yBy:-coords[2]];
	}else {
		[NSException raise:@"DBInvalidArgumentException"
					format:@"String passed for initializing affine transform not valid (rotate)"];
	}
}

- (void)_initMatrix:(NSString *)s
{
	float * coords;
	int count;
	
	coords = [s getFloats:&count];
	
	
	if(count == 6){
		NSAffineTransformStruct ats;
		ats.m11 = coords[0];
		ats.m12 = coords[1];
		ats.m21 = coords[2];
		ats.m22 = coords[3];
		ats.tX = coords[4];
		ats.tY = coords[5];

//		NSLog(@"init matrix %f %f %f %f %f %f",ats.m11, ats.m12, ats.m21, ats.m22, ats.tX, ats.tY);

		[self setTransformStruct:ats];
	}else {
		[NSException raise:@"DBInvalidArgumentException"
					format:@"String passed for initializing affine transform not valid (matrix)"];
	}
}

- (void)_initSkewX:(NSString *)s
{
	float * coords;
	int count;
	
	coords = [s getFloats:&count];
	
	if(count == 1){
		NSAffineTransformStruct ats;
		ats.m11 = 1.0;
		ats.m12 = 0.0;
		ats.m21 = tan(coords[0]*(M_PI/180));
		ats.m22 = 1.0;
		ats.tX = 0.0;
		ats.tY = 0.0;
		
		[self setTransformStruct:ats];
	}else {
		[NSException raise:@"DBInvalidArgumentException"
					format:@"String passed for initializing affine transform not valid (skewX)"];
	}
}

- (void)_initSkewY:(NSString *)s
{
	float * coords;
	int count;
	
	coords = [s getFloats:&count];
	
	if(count == 1){
		NSAffineTransformStruct ats;
		ats.m11 = 1.0;
		ats.m12 = tan(coords[0]*(M_PI/180));
		ats.m21 = 0.0;
		ats.m22 = 1.0;
		ats.tX = 0.0;
		ats.tY = 0.0;
		
		[self setTransformStruct:ats];
	}else {
		[NSException raise:@"DBInvalidArgumentException"
					format:@"String passed for initializing affine transform not valid (skewY)"];
	}
}

@end
