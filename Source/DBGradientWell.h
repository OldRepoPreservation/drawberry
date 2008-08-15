//
//  DBGradientWell.h
//  DrawBerry
//
//  Created by Raphael Bost on 25/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCGradient;

@interface DBGradientWell : NSControl {

}
- (GCGradient *)gradient;
- (void)setGradient:(GCGradient *)newGradient;

@end
