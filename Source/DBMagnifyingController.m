//
//  DBMagnifyingController.m
//  DrawBerry
//
//  Created by Raphael Bost on 09/09/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBMagnifyingController.h"
#import "DBMagnifyingView.h"

static DBMagnifyingController *_sharedMagnifyingController = nil;

@implementation DBMagnifyingController

+ (id)sharedMagnifyingController
{
    if (!_sharedMagnifyingController) {
        _sharedMagnifyingController = [[DBMagnifyingController allocWithZone:[self zone]] init];
    }
    return _sharedMagnifyingController;
}

+ (DBMagnifyingView *)sharedMagnifyingView
{
	return [[self sharedMagnifyingController] magnifyingView];
}

- (id)init {
    self = [self initWithWindowNibName:@"DBMagnifyingGlass"];
    if (self) {
        [self setWindowFrameAutosaveName:@"DBMagnifyingGlass"];
    }
    return self;
} 

- (DBMagnifyingView *)magnifyingView
{
	return _magnifyingView;
}
@end
