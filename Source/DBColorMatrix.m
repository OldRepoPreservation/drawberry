//
//  DBColorMatrix.m
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBColorMatrix.h"

#import "DBColorCell.h"

@implementation DBColorMatrix

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	[self setAutoresizeWindow:YES];
	return self;
}

- (Class)cellClass
{
	return [DBColorCell class];
}

@end
