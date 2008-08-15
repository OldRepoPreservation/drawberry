//
//  DBUndoObject.h
//  DrawBerry
//
//  Created by Raphael Bost on 23/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBUndoObject : NSObject {
	NSInvocation *_invocation;
	id _target;
	NSString *_actionName;
	id _userInfo;
}
- (id)initWithTarget:(id)target invocation:(NSInvocation *)invocation actionName:(NSString *)name;
- (void)invoke;
- (NSString *)actionName;
- (void)setActionName:(NSString *)aValue;
- (id)userInfo;
- (void)setUserInfo:(id)aValue;
- (id)target;
- (NSInvocation *)invocation;
@end
