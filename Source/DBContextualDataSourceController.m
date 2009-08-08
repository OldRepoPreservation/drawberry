//
//  DBContextualDataSourceController.m
//  DrawBerry
//
//  Created by Raphael Bost on 24/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBContextualDataSourceController.h"

#import "DBDrawingView.h"
#import "DBDrawingView+ShapeManagement.h"
#import "DBDrawingView+BooleanOps.h"

#import "DBContextualBar.h"

#import "DBShape.h"
#import "DBText.h"
#import "DBOval.h"
#import "DBPolyline.h"
#import "DBBezierCurve.h"


#import "EMErrorManager.h"

@class DBRectangle, DBOval, DBText,DBBezierCurve,DBPolyline;

@implementation DBContextualDataSourceController

- (id)init
{
	self = [super init];
	
	[NSBundle loadNibNamed:@"DBContextualViews" owner:self];
	
	return self;
}

- (void)awakeFromNib
{
	[_contextualBar reloadDataSource];
	
	[_booleanOp setImage:[NSImage imageNamed:@"boolean_on"]];   
	
	// [_contextualBar retain];
	// NSView *v = [_contextualBar superview];
	// [_contextualBar removeFromSuperview];
	// [v addSubview:_contextualBar];
	// [_contextualBar release];    
}                               

- (int)numberOfItems
{
	return 1;
}

- (NSView *)itemAtIndex:(int)index
{
//	NSLog(@"item at index, selection type %d",_selectionType);
	if(_selectionType == 0){
		return _voidView;	
	}else if(_selectionType == 1){
		return _selectView;		
	}else if(_selectionType == 2){
		if([[_mainView selectedShape] isKindOfClass:[DBText class]]){
			return _textView;
		}else if([[_mainView selectedShape] isKindOfClass:[DBRectangle class]]){
			return _rectangleView;
		}else if([[_mainView selectedShape] isKindOfClass:[DBOval class]]){
			return _ovalView;
		}else{
			return _bezierView;
		}
	}                     
	
	return nil;
}

- (void)updateSelection
{
	int oldSelectionType;
	DBShape *shape;
	
	shape = nil;
	
	oldSelectionType = _selectionType;
	
	if([[_mainView selectedShapes] count]>0){
		_selectionType = 1;
		shape = [[_mainView selectedShapes] objectAtIndex:0];
	}else if([_mainView editingShape]){
		shape = [_mainView editingShape];
		_selectionType = 2;
	}else{
		_selectionType = 0;
	}
	         
	[_convertBox setHidden:YES];
	[_textEditBox setHidden:YES]; 
//	[_booleanOp setHidden:YES];
//	[_alignment setHidden:YES];
	[_multipleSelectionBox setHidden:YES];
	[_replaceButton setHidden:YES]; 
	
	BOOL flag;
	flag = YES;

 //   	NSLog(@"selectedShapes : %d", [[_mainView selectedShapes] count]);
	if([[_mainView selectedShapes] count] > 1){
    	[_multipleSelectionBox setHidden:NO];

	}else if([shape isKindOfClass:[DBText class]]){
		[_textEditBox setHidden:NO];
		                            
//		[_alignControl setSelected:YES forSegment:[[_alignControl cell] segmentWithTag:[[_mainView selectedShape] textAlignment]]];
		[_alignControl selectSegmentWithTag:[(DBText *)[_mainView selectedShape] textAlignment]];
		[_vertAlignControl selectSegmentWithTag:[(DBText *)[_mainView selectedShape] textVerticalPositon]];
		
	}else if([shape isKindOfClass:[DBRectangle class]]){
		[_convertBox setHidden:NO];
		[_convertButton setImage:[NSImage imageNamed:@"transformRect"]];
		
	}else if([shape isKindOfClass:[DBOval class]]){
		[_convertBox setHidden:NO];
		[_convertButton setImage:[NSImage imageNamed:@"transformOval"]];
		
	}else if([shape isKindOfClass:[DBPolyline class]]){
		[_replaceButton setHidden:NO];
		[_replaceButton setImage:[NSImage imageNamed:@"replacePoly"]];
		
	}else if([shape isKindOfClass:[DBBezierCurve class]]){
		[_replaceButton setHidden:NO];
		[_replaceButton setImage:[NSImage imageNamed:@"replaceBezier"]]; 
		
	}else{
//		[_convertBox setHidden:YES];
//		[_textEditBox setHidden:YES];
	}                                
	
	if(oldSelectionType != _selectionType){
//		[_contextualBar updateViewForDataSource];	
		[_contextualBar changeForDataSource:self animate:YES];
	}else {
//		NSLog(@"selection type did not change");
	}

}

- (void)beginEditing
{
	_selectionType = 2;
//	[self updateSelection];
	[_contextualBar updateViewForDataSource];
}

- (void)endEditing
{
	if([_mainView selectedShape]){
		_selectionType = 1;
	}else{
		_selectionType = 0;
	}
	[_contextualBar updateViewForDataSource];

}

- (IBAction)duplicate:(id)sender
{
	[_mainView duplicateSelectedShapes];
}   

- (IBAction)delete:(id)sender
{
	[_mainView deleteSelectedShapes];
}

- (IBAction)addControlPoint:(id)sender
{
	[[_mainView editingShape] addPoint:sender];
}   

- (IBAction)removeControlPoint:(id)sender
{
	[[_mainView editingShape] delete:sender];
	
}

- (IBAction)replace:(id)sender
{
	BOOL success;
	success = [[_mainView editingShape] replaceInView:_mainView];
	
	if(!success){
		[[_mainView errorManager] postErrorName:@"Error when replacing path" description:@"You must choose exactly 2 control points"];
	}
}

- (IBAction)convert:(id)sender
{
	[_mainView convertSelectedShapesToBezier];
}

- (IBAction)align:(id)sender
{
//	[[_mainView selectedShape] setTextAlignment:[sender selectedSegment]];
	[(DBText *)[_mainView selectedShape] setTextAlignment:[[sender cell] tagForSegment:[sender selectedSegment]]];
}

- (IBAction)vertAlign:(id)sender
{
	[(DBText *)[_mainView selectedShape] setTextVerticalPositon:[sender selectedSegment]];
} 

- (IBAction)stopEditing:(id)sender
{
	id shape = [_mainView editingShape];
	
	[_mainView stopEditingShape];
	
	[_mainView selectShape:shape];
}

- (IBAction)raise:(id)sender
{
	[_mainView raiseSelectedShapes:sender];
} 

- (IBAction)lower:(id)sender
{
	[_mainView lowerSelectedShapes:sender];	
}

#pragma mark Bool ops

- (IBAction)union:(id)sender
{
	[_mainView unionSelectedObjects:sender];
}   

- (IBAction)diff:(id)sender
{
	[_mainView diffSelectedObjects:sender];
}   

- (IBAction)intersection:(id)sender
{
	[_mainView intersectionSelectedObjects:sender];
}   

- (IBAction)xor:(id)sender
{
	[_mainView xorSelectedObjects:sender];
}   

#pragma mark Align
- (IBAction)left:(id)sender
{
	[_mainView alignLeft:sender];
}  
- (IBAction)center:(id)sender
{
	[_mainView alignCenter:sender];
}
- (IBAction)right:(id)sender
{
	[_mainView alignRight:sender];
}
- (IBAction)top:(id)sender
{
	[_mainView alignTop:sender];
}  
- (IBAction)middle:(id)sender
{
	[_mainView alignMiddle:sender];
}
- (IBAction)bottom:(id)sender
{
	[_mainView alignBottom:sender];
}
@end
