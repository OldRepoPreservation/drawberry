//
//  DBMatrix.h
//  DBColorSwatchApp
//
//  Created by Raphael Bost on 08/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBMatrixDataSource.h"

@interface NSMatrix (DBMatrixAdditions)	
- (NSCell *)cellAtPoint:(NSPoint)p;
@end

@interface DBMatrix : NSMatrix {
	IBOutlet id <DBMatrixDataSource> _dataSource;
	
	id _draggedObject;
	id _clickedObject;
	NSCell *_cellUnderMouse;
	
	BOOL _autoresizeWindow;
}
- (id)dataSource;
- (void)setDataSource:(id <DBMatrixDataSource>)dataSource;
           
- (void)updateNumbersOfRowsAndColumns;
- (void)updateWindowSize;

- (void)reloadData;
- (void)reloadDataInRange:(NSRange)range; 

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (NSCell *)cellUnderMouse;
- (NSCell *)cellAtIndex:(int)index;

- (BOOL)autoresizeWindow;
- (void)setAutoresizeWindow:(BOOL)flag;
@end                        


