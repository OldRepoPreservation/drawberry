//
//  DBShapeCollection.h
//  DrawBerry
//
//  Created by Raphael Bost on 26/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBShapeCollection : NSObject {
	NSMutableArray *_shapes;
	NSString *_name;
	BOOL _editable;
}
+ (id)collection;
+ (NSString *)builtInCollectionsPath;
- (id)initWithName:(NSString *)name;
- (id)initWithContentsOfFile:(NSString *)path;

- (NSString *)name;
- (void)setName:(NSString *)newName;
- (void)addShape:(id)aShape;
- (void)insertShape:(id)aShape atIndex:(unsigned int)i;
- (id)shapeAtIndex:(unsigned int)i;
- (unsigned int)indexOfShape:(id)aShape;
- (void)removeShape:(id)aShape;
- (void)removeShapeAtIndex:(unsigned int)i;
- (NSArray *)shapes;
- (void)setShapes:(NSArray *)newShapes;
- (BOOL)editable;
- (void)setEditable:(BOOL)newEditable;

- (NSString *)filename;
- (BOOL)writeAtomically:(BOOL)flag;
- (BOOL)removeStorage;
@end
