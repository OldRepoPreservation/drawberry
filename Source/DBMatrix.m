//
//  DBMatrix.m
//  DBColorSwatchApp
//
//  Created by Raphael Bost on 08/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBMatrix.h"

@implementation NSMatrix (DBMatrixAdditions)	
- (NSCell *)cellAtPoint:(NSPoint)p	
{
	int i, j;
	[self getRow:&j column:&i forPoint:p];
	return [self cellAtRow:j column:i];
}
@end                        

@implementation DBMatrix
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
                            
	[self setCellClass:[self cellClass]];
    
	[self setCellSize:NSMakeSize(13,13)];
	
	[self updateNumbersOfRowsAndColumns];
	
	[self updateWindowSize];
	
	return self;
}

- (void)awakeFromNib
{                        
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents:YES];    

	[self updateNumbersOfRowsAndColumns];
	_autoresizeWindow = NO;
	[self updateWindowSize];
	
	[self reloadData];
	[self registerForDraggedTypes:[_dataSource draggedTypes]];
}                     

- (Class)cellClass // you MUST override this method to put the correct cell class, otherwise you will get an error at runtime
{	
	return nil;
}          

- (BOOL)autoresizeWindow
{
	return _autoresizeWindow;
}
- (void)setAutoresizeWindow:(BOOL)flag
{
	_autoresizeWindow = flag;
	[self updateWindowSize];
}

- (void)updateNumbersOfRowsAndColumns
{
	int rows, columns;
	columns = floorf( ([self frame].size.width + [self intercellSpacing].width) / [self cellSize].width) ;
	rows = floorf( ([self frame].size.height + [self intercellSpacing].height) / [self cellSize].height) ;

	if(columns != [self numberOfColumns] || rows != [self numberOfRows]){
		[self renewRows:rows columns:columns];
	}
}

- (void)updateWindowSize
{              
	if(!_autoresizeWindow){
		return;
	}
	
//	NSLog(@"updateWindowSize");
	NSRect frame, bounds, newFrame;
	frame = [[self window] frame];
	bounds = [self bounds];
	
	int rows, cols;
	cols = [self numberOfColumns];
	rows = ceil([_dataSource numberOfObjects] / ((float)cols));

	newFrame = frame;
	
	newFrame.size.height = rows * ([self cellSize].height + [self intercellSpacing].height) 
							+ frame.size.height - bounds.size.height;
	
	newFrame.size.height = MAX(newFrame.size.height,[[self window] minSize].height);
    [[self window] setFrame:newFrame display:YES animate:YES];

	[self renewRows:rows columns:cols];
}   

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
	[super resizeWithOldSuperviewSize:oldBoundsSize];
}

- (id)dataSource
{
	return _dataSource;
}

- (void)setDataSource:(id <DBMatrixDataSource>)newDataSource
{
	_dataSource = newDataSource;
}

- (void)reloadData
{      
	[self updateWindowSize];
	[self reloadDataInRange:NSMakeRange(0,[self numberOfColumns]*[self numberOfRows])];
}   

- (void)reloadDataInRange:(NSRange)range
{
	[self updateWindowSize];
	int i, row, column;
	NSCell *cell;

	for( i = 0; i < range.length; i++ )
	{
		column = (i + range.location)%[self numberOfColumns];
		row = (int) ((i + range.location) - column) / [self numberOfColumns];
		
		cell = [self cellAtRow:row column:column];
		
		
		if(i < [_dataSource numberOfObjects]){
		   	[cell setObjectValue:[_dataSource objectAtIndex:(i + range.location)]];
		}else{    
			[cell setObjectValue:nil];
		}
	}

	_cellUnderMouse = nil;
	[self setNeedsDisplay:YES];
}

- (NSCell *)cellAtIndex:(int)index
{
	int row, column;
	column = (index)%[self numberOfColumns];
	row = (int) ((index) - column) / [self numberOfColumns];
	
	return [self cellAtRow:row column:column];
}
- (void)setCellSize:(NSSize)s
{
	[super setCellSize:s];
	
	[self updateNumbersOfRowsAndColumns];
	[self updateWindowSize];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
 	return NSDragOperationLink;
}
                                      
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{                     
	id draggedData;
	
	draggedData = [_dataSource readObjectFromPasteboard:[sender draggingPasteboard]];
	
	if([draggedData isKindOfClass:[NSArray class]] || [draggedData isKindOfClass:[NSSet class]]){
		NSEnumerator *e = [draggedData objectEnumerator];
		id object;

		while((object = [e nextObject])){
			[_dataSource addObject:object]; 
		}
	}else{
		[_dataSource addObject:draggedData]; 
	}
	
	[self reloadDataInRange:NSMakeRange([_dataSource numberOfObjects]-1,1)];
		     
	return YES;
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationLink;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{                        
//	if(!_draggedObject){
		id object;
		NSPoint point;
		
		point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		object = [[self cellAtPoint:point] objectValue];
		
		if(object){                                  
			_clickedObject = object;
		}else{
			_clickedObject = nil;
		}		
//	}

	return [self menu];
}

- (void)mouseDown:(NSEvent *)event
{
	_draggedObject = nil;
}

- (void)mouseDragged:(NSEvent *)event
{
	if(!_draggedObject){
		id object;
		NSPoint point;
		
		point = [self convertPoint:[event locationInWindow] fromView:nil];
		object = [[self cellAtPoint:point] objectValue];
		
		if(object){                                  
			_draggedObject = object;
			
			[_dataSource writeObject:_draggedObject toPasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]];
			[_dataSource dragObject:_draggedObject withEvent:event pasteBoard:[NSPasteboard pasteboardWithName:NSDragPboard]];
		}else{
			_draggedObject = nil;
		}	
	}else {

	}

}   

- (void)mouseUp:(NSEvent *)event
{
	_draggedObject = nil;
}

- (IBAction)add:(id)sender
{
	[_dataSource addObject:nil];
	[self reloadData];
}
- (IBAction)remove:(id)sender
{
	[_dataSource removeObject:_clickedObject];
	_clickedObject = nil;
	
	[self reloadData];
}

- (void)mouseMoved:(NSEvent *)theEvent
{         
	id oldCell;
	
	oldCell = _cellUnderMouse;
	if(NSPointInRect([theEvent locationInWindow], [self frame])){
		_cellUnderMouse = [self cellAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
		
		if(![_cellUnderMouse objectValue]){
			_cellUnderMouse = nil;
		}
	}else{
		_cellUnderMouse = nil;
	}
    
	if(oldCell != _cellUnderMouse){
		[self setNeedsDisplay:YES];
	}
	[super mouseMoved:theEvent];
}

- (NSCell *)cellUnderMouse
{
	return _cellUnderMouse;
}
@end
