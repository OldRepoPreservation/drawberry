//
//  DBShapeLibEditingView.m
//  DrawBerry
//
//  Created by Raphael Bost on 19/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBShapeLibEditingView.h"

#import "DBShapeLibLayerController.h"

@implementation DBShapeLibEditingView

/*- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	            
	
	return self;
} */
- (void)awakeFromNib
{
	[super awakeFromNib];
	[[self enclosingScrollView] setRulersVisible:NO];
	
	[self setCanevasSize:[[self enclosingScrollView] contentSize]];
//	[self setCanevasSize:[[self enclosingScrollView] frame].size];
	
	[self updateFrameOrigin];
	[self updateCanevasOrigin];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType,  nil]];
	
}

- (DBLayerController *)layerController
{
	return _layerController;
}

- (void)deleteSelectedShapes
{
	[_layerController removeEditedShape];

	[super deleteSelectedShapes];
	
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{                                              
	BOOL result;
	
	result = [super performDragOperation:sender];
	
	if(result){
		[[self layerController] endEditing];
	}              
	
	return result;
}
/*- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent keyCode] ==  51 && _editingShape){
		[_layerController removeEditedShape];
		[_editingShape delete:self]; // override to get a good behavior
	}else{
		[super keyDown:theEvent];
	}
}*/
@end
