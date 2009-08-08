//
//  DBUndoObject.m
//  DrawBerry
//
//  Created by Raphael Bost on 23/07/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBUndoObject.h"


@implementation DBUndoObject
- (id)initWithTarget:(id)target invocation:(NSInvocation *)invocation actionName:(NSString *)name
{
	self = [super init];
		
	_target = [target retain];
	_invocation = [invocation retain];
	[_invocation retainArguments];
	[self setActionName:name];
	return self;
}

- (void)dealloc
{
	[_invocation release];
	[_actionName release];
	[_userInfo release];
	
	[super dealloc];
}       

- (void)invoke
{
	[_invocation invokeWithTarget:_target];
}

- (NSString *)actionName
{
	return _actionName;
}

- (void)setActionName:(NSString *)newActionName
{
	if(!newActionName){
		newActionName = @"";
	}

	[newActionName retain];
	[_actionName release];
	_actionName = newActionName;  
	
}

- (id)target
{
	return _target;
}  

- (NSInvocation *)invocation
{
	return _invocation;
}

- (id)userInfo
{
	return _userInfo;
}

- (void)setUserInfo:(id)newUserInfo
{
	[newUserInfo retain];
	[_userInfo release];
	_userInfo = newUserInfo;
}
@end
