//
//  DBGroup.h
//  DrawBerry
//
//  Created by Raphael Bost on 29/04/12.
//  Copyright 2012 Ecole Polytechnique. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBGroupController.h"
#import "DBShape.h"

@interface DBGroup : NSObject {
@private
    NSString *_name;
    
    DBGroupController *_groupController;
    
    NSMutableArray *_shapes;
}
- (id)initWithName:(NSString *)aName;

- (NSString *)name;
- (void)setName:(NSString *)aName;

- (DBGroupController *)groupController;
- (void)setGroupController:(DBGroupController *)gpCtrl;

- (void)addShape:(DBShape *)aShape;
- (void)addShapes:(NSArray *)someShapes;
- (void)insertShape:(DBShape *)aShape atIndex:(unsigned int)i;
- (DBShape *)shapeAtIndex:(unsigned int)i;
- (unsigned int)indexOfShape:(DBShape *)aShape;
- (void)removeShape:(DBShape *)aShape;
- (void)removeShapes:(NSArray *)shapes;
- (void)removeShapeAtIndex:(unsigned int)i;
- (unsigned int)countOfShapes;
- (NSArray *)shapes;
- (void)setShapes:(NSArray *)newShapes;

- (void)setShapesGroup;
- (void)unsetShapesGroup;

- (NSArray *)shapeLayers;

- (NSRect)enclosingRect;
- (void)displayEnclosingRect;

- (int)knobUnderPoint:(NSPoint)point;
- (NSPoint)pointForKnob:(int)knob;



- (void)moveGroupByX:(float)deltaX byY:(float)deltaY;

- (int)resizeByMovingKnob:(int)knob fromPoint:(NSPoint)fromPoint toPoint:(NSPoint)point inView:(DBDrawingView *)view modifierFlags:(unsigned int)flags;
- (void)flipVerticallyWithNewKnob:(int)knob;
- (void)flipHorizontalyWithNewKnob:(int)knob;
- (void)putPathInRect:(NSRect)newRect;

@end

NSRect DBNewRectWhenResizing(NSRect originalRect,NSRect originalContainer, NSRect newContainer);

