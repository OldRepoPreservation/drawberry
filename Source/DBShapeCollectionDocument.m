//
//  DBShapeCollectionDocument.m
//  DrawBerry
//
//  Created by Raphael Bost on 02/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBShapeCollectionDocument.h"
#import "DBShapeCollection.h"
#import "DBShapeLibraryController.h"

@implementation DBShapeCollectionDocument
               
- (void)dealloc
{	
	[_collection release];
	
	[super dealloc];
}
- (void)awakeFromNib
{
	NSString *description, *name;
	int i;                      
	name  = [_collection name];
	description = [NSString stringWithFormat:NSLocalizedString(@"Shape collection import desc",nil),name,[[_collection shapes] count],nil];

	i = 1;
	while([[NSFileManager defaultManager] fileExistsAtPath:[_collection filename]]){
		[_collection setName:[NSString stringWithFormat:@"%@ - %d",name,i,nil]];
		i++;
	}
	
	[_descriptionField setStringValue:description];
}
- (NSString *)windowNibName {
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"DBShapeCollectionDocument";
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	_collection = [[DBShapeCollection alloc] initWithContentsOfFile:[absoluteURL path]];
	
	return ((_collection == nil) ? NO : YES);
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{

}

- (IBAction)addCollection:(id)sender
{   
	BOOL succes;                               
	NSLog(@"collection %@", _collection);
	succes = [_collection writeAtomically:NO];
	
	if(!succes){
		NSBeep();
	}else{
		[[DBShapeLibraryController sharedShapeLibraryController] updateCollectionList];
	}
	[self close];
}

- (IBAction)cancel:(id)sender
{
	[self close];
}

- (id)specialUndoManager
{
	return nil;
}
@end
