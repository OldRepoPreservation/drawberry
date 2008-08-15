//
//  DBDrawingView+Undo.h
//  DrawBerry
//
//  Created by Raphael Bost on 24/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBDrawingview.h"

@interface DBDrawingView (Undo)
- (void)translateShapes:(NSArray *)shapes vector:(NSPoint)vector;
- (void)resizeShape:(DBShape *)shape withKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point;
- (void)rotateShape:(DBShape *)shape withAngle:(float)angle;
@end
