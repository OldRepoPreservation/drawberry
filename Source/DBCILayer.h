//
//  DBCILayer.h
//  DrawBerry
//
//  Created by Raphael Bost on 30/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBLayer.h"


@class DBFilterStack;

@interface DBCILayer : DBLayer {
	CIImage *_ciRender;
	DBFilterStack *_filterStack;
}
- (BOOL)drawUnderneathLayers;
- (NSArray *)underneathLayers;
- (DBFilterStack *)filterStack;
- (void)drawFilterPoints;
- (BOOL)moveFilterPoints:(NSEvent *)theEvent inView:(DBDrawingView *)view;
@end
