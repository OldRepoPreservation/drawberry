//
//  DBShapeCollection.m
//  DrawBerry
//
//  Created by Raphael Bost on 26/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBShapeCollection.h"


@implementation DBShapeCollection
+ (NSString *)builtInCollectionsPath
{
	NSBundle *bundle;
	
	bundle = [NSBundle mainBundle];
	
	return [[bundle resourcePath] stringByAppendingPathComponent:@"Shape Collections"];
}           

+ (id)collection
{
	return [[[self alloc] init] autorelease];
}
- (id)init
{
	return [self initWithName:@"Untitled Collection"];
}

- (id)initWithName:(NSString *)name
{
	self = [super init];
	
	if(self){
		[self setName:name];
		_shapes = [[NSMutableArray alloc] init];
		_editable = YES;
//		NSLog(@"init with content shapes : %@", _shapes);
		
	}
	
	return self;
}

- (id)initWithContentsOfFile:(NSString *)path
{
	NSDictionary *dict;
	
	dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	
	if(!dict){
		NSLog(@"Error when opening collection at location %@", path);
		return nil;
	}              
	
	self = [self init];
	
	if(self){
		[self setName:[dict objectForKey:@"Collection Name"]];
		
		NSArray *array;
		array = [NSKeyedUnarchiver unarchiveObjectWithData:[dict objectForKey:@"Shape data"]];
		[self setShapes:array];                                                               
		
		path = [path stringByDeletingLastPathComponent];
		
		if([path isEqualTo:[DBShapeCollection builtInCollectionsPath]]){
			_editable = NO;
		}
	}
	
	return self; 
}

- (void)dealloc
{	
	[_name release];
	[_shapes release];
	
	[super dealloc];
}
 

- (id)copyWithZone:(NSZone *)zone 
{
	DBShapeCollection *collection;
	
	collection = [[DBShapeCollection alloc] initWithName:[NSString stringWithFormat:@"%@ - %@",[self name],NSLocalizedString(@"Copy",nil),nil]];
	                 
	NSData *data;
	
	data = [NSKeyedArchiver archivedDataWithRootObject:_shapes];
   	
	[collection setShapes:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	
	[collection setEditable:YES];
	return collection;
}

- (NSString *)name
{
	return _name;
}

- (void)setName:(NSString *)newName
{
//	[self removeStorage];
	[newName retain];
	[_name release];
	_name = newName;
//	[self writeAtomically:NO];
}

- (void)addShape:(id)aShape
{                       
	[_shapes addObject:aShape];
//	NSLog(@"add %@",_shapes);	
}

- (void)insertShape:(id)aShape atIndex:(unsigned int)i 
{
	[_shapes insertObject:aShape atIndex:i];
}

- (id)shapeAtIndex:(unsigned int)i
{        
//	NSLog(@"shape at index");
	return [_shapes objectAtIndex:i];
}

- (unsigned int)indexOfShape:(id)aShape
{
	return [_shapes indexOfObject:aShape];
}

- (void)removeShape:(id)aShape
{
	[_shapes removeObject:aShape];
}
- (void)removeShapeAtIndex:(unsigned int)i
{
	[_shapes removeObjectAtIndex:i];
}

- (unsigned int)countOfShapes
{
	return [_shapes count];
}

- (NSArray *)shapes
{
	return _shapes;
}

- (void)setShapes:(NSArray *)newShapes
{                               
	NSArray *oldShapes;
	oldShapes = _shapes;
	_shapes  = [newShapes mutableCopy];
	[oldShapes release];                   
	
	[_shapes makeObjectsPerformSelector:@selector(updatePath)];
	[_shapes makeObjectsPerformSelector:@selector(updateBounds)];
}
 
- (BOOL)editable
{
	return _editable;
}

- (void)setEditable:(BOOL)newEditable
{
	_editable = newEditable;
}

#pragma mark Writing and Reading from disk
+ (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"DrawBerry"];
}

- (NSString *)filename
{
	NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [DBShapeCollection applicationSupportFolder];
    
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }

	return [NSString stringWithFormat:@"%@/%@.dblib",applicationSupportFolder,[self name]];
}

- (BOOL)writeAtomically:(BOOL)flag
{                   
	if(!_editable){
		return YES;
	}
	NSDictionary *dict;
	NSData *shapeData;
	BOOL result;
	
	shapeData = [NSKeyedArchiver archivedDataWithRootObject:_shapes];
	dict = [[NSDictionary alloc] initWithObjectsAndKeys:[self name],@"Collection Name",shapeData,@"Shape data",nil];

	result = [dict writeToFile:[self filename] atomically:flag];
	
	return result;
}

- (BOOL)removeStorage
{
	NSFileManager *fileManager;
    fileManager = [NSFileManager defaultManager];
	
	if([fileManager fileExistsAtPath:[self filename]]){
		return [fileManager removeFileAtPath:[self filename] handler:nil];
	}
	
	return YES;
}

- (NSComparisonResult)compare:(DBShapeCollection *)collection
{
	return [_name caseInsensitiveCompare:[collection name]];
}
@end
