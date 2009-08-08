//
//  NSString+Extensions.m
//  DrawBerry
//
//  Created by Raphael Bost on 12/06/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import "NSString+Extensions.h"


@implementation NSString (DBExtension)
- (float *)getFloats:(int *)count
{
	NSArray *a;
	int c;
	NSEnumerator *e;
	NSString *s;
	float *f;
	
	a = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
	c = 0;
	e = [a objectEnumerator];
	
	f = malloc([a count]*sizeof(float));
	
	while ((s = [e nextObject])) {
		if([s length] > 0){
			f[c] = [s floatValue];
			c++;
		}
	}
	
	f = realloc(f, c*sizeof(float));
	
	if(count != NULL){
		*count = c;
	}
	
	return f;
}
@end
