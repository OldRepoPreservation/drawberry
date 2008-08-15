//
//  DBButtonCell.h
//  DrawBerry
//
//  Created by Raphael Bost on 12/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBButtonCell : NSButtonCell {
	BOOL _locked;
}
- (BOOL)isLocked;
- (void)setLocked:(BOOL)newLocked;
@end
