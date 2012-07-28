//
//  DBShapeMatrix.m
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBShapeMatrix.h"

#import "DBShapeCell.h"

NSString *DBSelectedCellDidChange = @"Selected Cell did change";

@implementation DBShapeMatrix
- (Class)cellClass
{
	return [DBShapeCell class];
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	[self setAutoresizeWindow:YES];
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_currentShapeCell = [self cellAtRow:0 column:0];
}

- (void)mouseDown:(NSEvent *)event
{
	[super mouseDown:event];
	
	if([event clickCount] == 2){
			[_dataSource doubleClickAction:self];		
	}else{
		NSPoint point;
	
		point = [self convertPoint:[event locationInWindow] fromView:nil];
		_draggedCell = [self cellAtPoint:point];
	}
}
                             
- (void)mouseUp:(NSEvent *)theEvent
{   NSPoint point;

	point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	_currentShapeCell = [self cellAtPoint:point];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:DBSelectedCellDidChange object:self];
	
	[super mouseUp:theEvent];
	
	_draggedCell = nil;
}

- (id)currentShapeCell
{
	return _currentShapeCell;
}
- (void)setCurrentShapeCell:(NSCell *)cell
{
	_currentShapeCell = cell;
	[[NSNotificationCenter defaultCenter] postNotificationName:DBSelectedCellDidChange object:self];
} 


- (void)updateWindowSize
{
	NSRect frame, newFrame;
	frame = [self  frame];
	int rows, cols;
	cols = [self numberOfColumns];

    if([self enclosingScrollView]){
		cols = MAX(cols,ceilf([[self enclosingScrollView] contentSize].width / ([self cellSize].height+[self intercellSpacing].width)) );
	}

    rows = ceil([_dataSource numberOfObjects] / ((float)cols));
    
	if([self enclosingScrollView]){
		rows = MAX(rows,ceilf([[self enclosingScrollView] contentSize].height / ([self cellSize].height+[self intercellSpacing].height)) );
	}
	newFrame = frame;

	newFrame.size.height = rows * ([self cellSize].height + [self intercellSpacing].height); 
	newFrame.size.width = cols * ([self cellSize].width + [self intercellSpacing].width); 
	
	[self setFrame:newFrame];
    
	[self renewRows:rows columns:cols];
}

- (void)mouseDragged:(NSEvent *)event
{
    [super mouseDragged:event];
	if(_draggedObject){
		NSImage *image;
		NSPoint point;
		NSRect cellFrame;
		int row,col;
		
		point = [self convertPoint:[event locationInWindow] fromView:nil];
		
		image = [[NSImage alloc] initWithSize:[self cellSize]];
		
		[self getRow:&row column:&col ofCell:_draggedCell];
		cellFrame = [self cellFrameAtRow:row column:col];

		if(NSAppKitVersionNumber <= NSAppKitVersionNumber10_5_3){
            [image setFlipped:YES]; //deprecated in 10.6
            [image lockFocus];
        }else{
            [image lockFocusFlipped:YES];
        }
        
		NSAffineTransform *at;
		at = [NSAffineTransform transform];
		[at translateXBy:-cellFrame.origin.x yBy:-cellFrame.origin.y];
		
		[NSGraphicsContext saveGraphicsState];
		[at concat];
		
		[_draggedCell drawWithFrame:cellFrame inView:nil];
		
		[NSGraphicsContext restoreGraphicsState];
		
		[image unlockFocus];
		
		point.x -= [image size].width/2;
		point.y += [image size].height/2;
		
		
		[self dragImage:image at:point offset:NSMakeSize(0,0) event:event pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard] source:self slideBack:NO];
		
		[image release];
	}
}

- (void)setFrame:(NSRect)frameRect
{
    NSRect oldRect = [self frame];
    [super setFrame:frameRect];
    
    if (!NSEqualRects(frameRect, oldRect)) {
        [self updateWindowSize];
    }
}
@end
