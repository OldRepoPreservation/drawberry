//
//  DBMagnifyingWindow.h
//  DrawBerry
//
//  Created by Raphael Bost on 02/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *DBMagnifyingWindowDidMove;

@interface DBMagnifyingWindow : NSPanel {
	NSPoint _movingVec;
}

@end
