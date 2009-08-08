//
//  DBContextualBar.h
//  ContextualToolBar
//
//  Created by Raphael Bost on 24/02/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@protocol DBContextualBarDataSource
- (int)numberOfItems;
- (NSView *)itemAtIndex:(int)index;
@end

@interface DBContextualBar : NSControl {
	NSViewAnimation *_activeAnimation;

	IBOutlet id <DBContextualBarDataSource> _dataSource;
	id _newDataSource;
	int _state; // 0 : nothing, 1 : opening, 2 : closing, 
				// 3 : changing data source (closing), 4 : updating data source (closing), 
}
- (IBAction)close:(id)sender;
- (IBAction)open:(id)sender ;

- (id <DBContextualBarDataSource>)dataSource;
- (void)setDataSource:(id <DBContextualBarDataSource>)aValue;

- (IBAction)reload:(id)sender;
- (void)reloadDataSource;	
- (void)changeForDataSource:(id <DBContextualBarDataSource>)newDataSource animate:(BOOL)flag;
- (void)updateViewForDataSource;
@end

