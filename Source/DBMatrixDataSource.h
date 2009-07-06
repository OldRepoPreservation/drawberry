/*
 *  DBMatrixDataSource.h
 *  DBColorSwatchApp
 *
 *  Created by Raphael Bost on 08/07/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
 
@protocol DBMatrixDataSource 
- (Class)cellClass;

- (int)numberOfObjects;
- (id)objectAtIndex:(int)index;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;

- (id)readObjectFromPasteboard:(NSPasteboard *)pb;                                   
- (void)writeObject:(id)object toPasteboard:(NSPasteboard *)pb;

- (NSArray *)draggedTypes;
- (void)dragObject:(id)object withEvent:(NSEvent *)theEvent pasteBoard:(NSPasteboard *)pboard;

@optional
- (void)doubleClickAction:(id)sender;
@end
