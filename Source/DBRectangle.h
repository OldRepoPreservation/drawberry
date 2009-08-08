//
//  DBRectangle.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBShape.h"

@class DBBezierCurve;

@interface DBRectangle : DBShape {
	NSPoint _point1, _point2, _point3, _point4; 
	NSBezierPath *_path;
	
	NSPoint _radiusKnob;
}
- (id)initWithRect:(NSRect)rect;

- (void)updatePath;
- (void)putPathInRect:(NSRect)newRect;

- (DBBezierCurve *)convertToBezierCurve;
@end
