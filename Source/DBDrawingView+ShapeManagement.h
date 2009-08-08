//
//  DBDrawingView+ShapeManagement.h
//  DrawBerry
//
//  Created by Raphael Bost on 02/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingView.h"

extern NSString *DBShapePboardType;

@interface DBDrawingView (ShapeManagement)

- (void)deleteSelectedShapes;
- (void)writeShapes:(NSArray *)shapes toPasteboard:(NSPasteboard *)pb;
- (NSArray *)shapesFromPasteboard:(NSPasteboard *)pb;
- (void)convertSelectedShapesToBezier;                                                                           

- (void)replaceShapes:(NSArray *)shapes byShapes:(NSArray *)newShapes actionName:(NSString *)actionName;
- (void)replaceShapes:(NSArray *)shapes byShape:(DBShape *)newShape actionName:(NSString *)actionName;
- (void)replaceShape:(DBShape *)oldShape byShapes:(NSArray *)newShapes actionName:(NSString *)actionName;

- (void)lowerShapesInArray:(NSArray *)shapes;
- (void)raiseShapesInArray:(NSArray *)shapes;
- (void)raiseSelectedShapes:(id)sender;
- (void)lowerSelectedShapes:(id)sender;

- (void)alignLeft:(id)sender;
- (void)alignCenter:(id)sender;
- (void)alignRight:(id)sender;
- (void)alignTop:(id)sender;
- (void)alignMiddle:(id)sender;
- (void)alignBottom:(id)sender;
@end
