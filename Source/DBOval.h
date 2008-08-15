//
//  DBRectangle.h
//  DrawBerry
//
//  Created by Raphael Bost on 16/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBShape.h"


@interface DBOval : DBShape {
	NSPoint _point1, _point2, _point3, _point4; 
	NSBezierPath *_path;
}
- (void)updatePath;
- (void)putPathInRect:(NSRect)newRect;
@end
