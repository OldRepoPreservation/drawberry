//
//  EMError.m
//  Error Manager App
//
//  Created by Raphael Bost on 28/10/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import "EMError.h"


@implementation EMError
+ (EMError *)errorWithName:(NSString *)name description:(NSString *)description
{
	return [self errorWithName:name description:description priority:0];
}
+ (EMError *)errorWithName:(NSString *)name description:(NSString *)description priority:(short int)p
{
	return [[[self alloc] initWithName:name description:description priority:p] autorelease];
}

- (id)initWithName:(NSString *)name description:(NSString *)description priority:(short int)p
{
	
	self = [super init];
	if (self != nil) {
		_name = [name retain];
		_description = [description retain];
		_priority = p;
	}
	return self;
}

- (void) dealloc {
	[_name release];
	[_description release];
	
	[super dealloc];
}

- (NSString *)name { return  _name; }
- (NSString *)description { return _description;}

@end
