//
//  DDDWindow.h
//  DockDockDock
//
//  Created by Raphael Bost on 22/02/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface DBWindow : NSWindow
{
	BOOL _appDidBecomeActive;
}
- (BOOL)appDidBecomeActive;
@end
