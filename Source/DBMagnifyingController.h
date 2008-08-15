//
//  DBMagnifyingController.h
//  DrawBerry
//
//  Created by Raphael Bost on 09/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBMagnifyingView;

@interface DBMagnifyingController : NSWindowController {
	IBOutlet DBMagnifyingView *_magnifyingView;
	
}   

+ (id)sharedMagnifyingController;
+ (DBMagnifyingView *)sharedMagnifyingView;
- (DBMagnifyingView *)magnifyingView;
@end
