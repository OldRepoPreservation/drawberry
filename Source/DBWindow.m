//
//  DDDWindow.h
//  DockDockDock
//
//  Created by Raphael Bost on 22/02/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBWindow.h"

@implementation DBWindow

- (void)sendEvent:(NSEvent *)theEvent
{
	_appDidBecomeActive = ![NSApp isActive];
	[super sendEvent:theEvent];
	_appDidBecomeActive = NO;
}

- (BOOL)appDidBecomeActive
{
	return _appDidBecomeActive;
}
@end
