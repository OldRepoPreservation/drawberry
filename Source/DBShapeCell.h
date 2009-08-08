//
//  DBShapeCell.h
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBShape;

@interface DBShapeCell : NSCell {
	DBShape *_shape;
}

- (DBShape *)shape;
- (void)setShape:(DBShape *)newShape;
@end
