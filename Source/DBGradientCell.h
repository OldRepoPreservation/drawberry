//
//  DBGradientCell.h
//  DrawBerry
//
//  Created by Raphael Bost on 25/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <GradientPanel/GradientPanel.h>

@interface DBGradientCell : NSCell {
	GCGradient *_gradient;
}
- (GCGradient *)gradient;
- (void)setGradient:(GCGradient *)aValue;

@end
