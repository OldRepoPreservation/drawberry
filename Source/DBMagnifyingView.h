//
//  DBMagnifyingView.h
//  DrawBerry
//
//  Created by Raphael Bost on 01/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _DBMagnifyingType{
	DBVectorialMagnifyingType = 100,
	DBPixellisationMagnifyingType,
}DBMagnifyingType;

@interface DBMagnifyingView : NSView {
	IBOutlet NSView *_source;
	NSPoint _magnifyingPoint;
	float _zoom;
	BOOL _isDrawing;
	BOOL _isResizing;
}

- (NSView *)source;
- (void)setSource:(NSView *)newSource;
- (NSPoint)magnifyingPoint;
- (void)setMagnifyingPoint:(NSPoint)newMagnifyingPoint;
- (float)zoom;
- (void)setZoom:(float)newZoom;
                                         
- (BOOL)isDrawingSource;
- (NSRect)sourceZoomedRect;

- (void)correctWindowPlace;
- (void)correctMagPoint;

- (IBAction)takeZoomValueFrom:(id)sender;
- (IBAction)update:(id)sender;
@end
