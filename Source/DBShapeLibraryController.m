//
//  DBShapeLibraryController.m
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBShapeLibraryController.h"
#import "DBShapeCell.h"

#import "DBRectangle.h"

#import "DBShapeLibLayerController.h"

#import "DDDAnimatedTabView.h"

#import "DBShapeCollection.h"


// NSString *DBShapePboardType = @"ShapePboardType";

static DBShapeLibraryController *_sharedShapeLibraryController = nil;

@implementation DBShapeLibraryController

+ (id)sharedShapeLibraryController 
{
    if (!_sharedShapeLibraryController) {
        _sharedShapeLibraryController = [[DBShapeLibraryController allocWithZone:[self zone]] init];
    }
    return _sharedShapeLibraryController;
}

+ (NSString *)applicationSupportFolder 
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"DrawBerry"];
}

- (id)init 
{
    self = [self initWithWindowNibName:@"DBShapeLibrary"];
    if (self) {                                 
		_shapeCollections = [[NSMutableArray alloc] init];
		
        [self setWindowFrameAutosaveName:@"DBShapeLibrary"];
    }
    return self;
}

- (void)dealloc
{
//	[_shapes release];
	[_shapeCollections release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[_matrix setCellSize:NSMakeSize(100,100)];
	[self readShapeLibrary];
	
	[_matrix reloadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCellDidChange:) name:DBSelectedCellDidChange object:_matrix];
}                                 

- (void)writeShapeLibrary
{
	NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [DBShapeLibraryController applicationSupportFolder];
    
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:NO attributes:nil error:NULL];
    }
	    
	if(![[self selectedCollection] writeAtomically:NO]){
		NSBeep();
		NSLog(@"error when writing shape lib");
	}
}

- (void)readShapeLibrary
{
	NSArray *files;
	NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
	NSString *builtInCollectionFolder;
	NSString *path;
	NSAutoreleasePool *pool;
	NSEnumerator *e;
	NSString * fileName;
	DBShapeCollection *collection;


    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [DBShapeLibraryController applicationSupportFolder];
	builtInCollectionFolder  = [DBShapeCollection builtInCollectionsPath];
		
	if ( [fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ){
//		[fileManager changeCurrentDirectoryPath:applicationSupportFolder];
		
		files = [fileManager contentsOfDirectoryAtPath:applicationSupportFolder error:NULL];
		
		e = [files objectEnumerator];		
		
		pool = [[NSAutoreleasePool alloc] init];
		while((fileName = [e nextObject])){
			if(![[fileName pathExtension] isEqualTo:@"dblib"]){
				continue;
			}
			path = [applicationSupportFolder stringByAppendingPathComponent:fileName];
			collection = [[DBShapeCollection alloc] initWithContentsOfFile:path];
			[_shapeCollections addObject:collection];
			[collection release];
		}
		[pool release];                                                                        
	}
	
	if([fileManager fileExistsAtPath:builtInCollectionFolder isDirectory:NULL]){
		files = [fileManager contentsOfDirectoryAtPath:builtInCollectionFolder error:NULL];
		
		e = [files objectEnumerator];		
		
		pool = [[NSAutoreleasePool alloc] init];
		while((fileName = [e nextObject])){
			if(![[fileName pathExtension] isEqualTo:@"dblib"]){
				continue;
			}
			path = [builtInCollectionFolder stringByAppendingPathComponent:fileName];
			collection = [[DBShapeCollection alloc] initWithContentsOfFile:path];
			[_shapeCollections addObject:collection];
			[collection release];
   		}
		[pool release];                                                                        		
	}
}
#pragma mark DBShapeMatrix data source & co
- (Class)cellClass
{
	return [DBShapeCell class];
}

- (int)numberOfObjects
{
	return [[[self selectedCollection] shapes] count];
}   

- (id)objectAtIndex:(int)index
{
	return [[self selectedCollection] shapeAtIndex:index];
}

- (void)addObject:(id)object
{
	if(![[self selectedCollection] editable]){
		return;
	}
	[[self selectedCollection] addShape:object];
	
	NSPoint vec;
//	vec = [object translationToCenterInRect:NSMakeRect(0,0,[_matrix cellSize].width,[_matrix cellSize].height)];
	vec = [object bounds].origin;
	[object moveByX:-vec.x byY:-vec.y];

	[object updatePath];
	[object updateBounds];

	[_matrix setCurrentShapeCell:[_matrix cellAtIndex:[[self selectedCollection] indexOfShape:object]]];
	[self writeShapeLibrary];
}

- (void)removeObject:(id)object
{
	if([[self selectedCollection] editable]){
		[[self selectedCollection] removeShape:object];
		[self writeShapeLibrary];
	}
}

- (id)readObjectFromPasteboard:(NSPasteboard *)pb;                                   
{
	NSData *pbData;
	NSString *type;
	id unarchivedData;

	type = [pb availableTypeFromArray:[NSArray arrayWithObject:@"ShapePboardType"]];
	
	if(type){
		pbData = [pb dataForType:@"ShapePboardType"];
	   	unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithData:pbData];
		
		return unarchivedData;
	}
	return nil;
}

- (void)writeObject:(id)object toPasteboard:(NSPasteboard *)pb
{
	if(![object isKindOfClass:[DBShape class]]){
		return;
	}
	[pb declareTypes:[NSArray arrayWithObject:@"ShapePboardType"] owner:self];
		
	NSData *shapesData;
	shapesData = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObject:object]];
	
	[pb setData:shapesData forType:@"ShapePboardType"];
}

- (NSArray *)draggedTypes
{
	return [NSArray arrayWithObjects:@"ShapePboardType",  nil];
}

- (void)dragObject:(id)object withEvent:(NSEvent *)theEvent pasteBoard:(NSPasteboard *)pboard
{
//	[_matrix dra];
}

- (IBAction)doubleClickAction:(id)sender
{            
	if([[self selectedCollection] editable])
		[_tabView selectEditor:sender];
}   

- (IBAction)reload:(id)sender
{
	[_matrix reloadData]; 
}

- (DBShape *)editedShape
{
	return [[_matrix currentShapeCell] objectValue];
}

- (void)newShape:(DBShape *)shape
{
//	NSLog(@"created shape %@", shape);
	if(!shape){
		return;
	}                           

	[[self selectedCollection] addShape:shape];                                                        
	[_matrix setCurrentShapeCell:[_matrix cellAtIndex:[[self selectedCollection] indexOfShape:shape]]];
	[_matrix reloadData];
    [_layerController editShape:shape];

	[self writeShapeLibrary];
}

- (void)removeEditedShape
{                  
	if([self editedShape]){
		[[self selectedCollection] removeShape:[self editedShape]];
		[_matrix reloadData];
		[self writeShapeLibrary];
	}
}

- (void)selectedCellDidChange:(NSNotification *)note
{
	[_layerController editShape:[self editedShape]];
	[_matrix reloadData];
}

- (IBAction)editDone:(id)sender
{
	[_tabView selectMatrix:sender];
}

- (IBAction)addShape:(id)sender
{
	if([[self selectedCollection] editable])
	{
		[_matrix setCurrentShapeCell:[_matrix cellAtIndex:[[[self selectedCollection] shapes] count]]];	
		[_tabView selectEditor:sender];		
	}
}

#pragma mark NSTableView data source & co
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_shapeCollections count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [[_shapeCollections objectAtIndex:rowIndex] name];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{                                                      
	DBShapeCollection *collection;
	 
	collection = [_shapeCollections objectAtIndex:rowIndex];
	if([[collection name] isEqualTo:anObject] || ![collection editable]){
		return; // nothing to do
	}else{
		NSEnumerator *e = [_shapeCollections objectEnumerator];
		DBShapeCollection * shapeCollection;

		while((shapeCollection = [e nextObject])){
			if([[shapeCollection name] isEqualTo:anObject]){   
				NSAlert *alert;
				alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Exiting name alert",nil) 
										defaultButton:@"OK" 
									  alternateButton:nil 
										  otherButton:nil 
				            informativeTextWithFormat:NSLocalizedString(@"Exiting name alert desc",nil)];
				[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
				
				return;
			}
		}
	}
	[collection removeStorage];
	[collection setName:anObject];
	[self writeShapeLibrary];

	[self sortCollections];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{                                                            	
	[_lockImage setHidden:[[self selectedCollection] editable]];
	[_matrix reloadData];
}

- (DBShapeCollection *)selectedCollection
{
	if ([_collectionView selectedRow] < [_shapeCollections count]) { 
		return [_shapeCollections objectAtIndex:[_collectionView selectedRow]];
	}
	return nil;
}

- (IBAction)addCollection:(id)sender
{
	[_shapeCollections addObject:[DBShapeCollection collection]];
	[self sortCollections];

	[_collectionView reloadData];
	[_matrix reloadData];
}

- (IBAction)removeCollection:(id)sender
{
	if(![[self selectedCollection] editable])
		return;
		
  	[_shapeCollections removeObject:[self selectedCollection]];
	[self sortCollections];

	[_collectionView reloadData];
	[_matrix reloadData];
}

- (IBAction)duplicateCollection:(id)sender
{
	DBShapeCollection *collection;
	
	if([self selectedCollection]){
		collection = [[self selectedCollection] copy];
		
		if([collection writeAtomically:NO])
		{
			[_shapeCollections addObject:collection];
			[self sortCollections];
			
			[_collectionView reloadData];
			[_matrix reloadData];
		}
        [collection release];
		
	}
}
- (void)sortCollections
{
	[_shapeCollections sortUsingSelector:@selector(compare:)];
}

- (void)updateCollectionList
{
	[_shapeCollections release];
	_shapeCollections = [[NSMutableArray alloc] init];
	
	[self readShapeLibrary];
	[_collectionView reloadData];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
{
	
}
@end
