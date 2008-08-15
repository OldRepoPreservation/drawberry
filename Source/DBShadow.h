//
//  DBShadow.h
//  DrawBerry
//
//  Created by Raphael Bost on 23/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBShape;

@interface DBShadow : NSShadow {	
	DBShape *_shape;
	BOOL _enabled;
}
- (id)initWithShape:(DBShape *)shape;

- (BOOL)enabled;
- (void)setEnabled:(BOOL)newEnabled;

- (void)setShadowOffset:(NSSize)newShadowOffset;
- (float)shadowOffsetWidth;
- (void)setShadowOffsetWidth:(float)newShadowOffsetWidth;
- (float)shadowOffsetHeight;
- (void)setShadowOffsetHeight:(float)newShadowOffsetHeight;
- (void)reverseShadowOffsetHeight;

- (DBShape *)shape;
- (void)setShape:(DBShape *)aShape;
@end
