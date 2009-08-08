//
//  DBLayerArrayController.h
//  DrawBerry
//
//  Created by Raphael Bost on 11/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBReverseArrayController : NSArrayController {
	BOOL _isReversed;
}
- (BOOL)isReversed;
- (void)setReversed:(BOOL)newIsReversed;
@end
