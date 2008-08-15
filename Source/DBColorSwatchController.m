//
//  DBColorSwatchController.m
//  DrawBerry
//
//  Created by Raphael Bost on 12/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBColorSwatchController.h"

//#import <DBMatrixFramework/DBMatrixDataSource.h>
#import "DBColorCell.h"

#import "NSColorList+Extension.h"

#import "DBPopUpButton.h"

static DBColorSwatchController *_sharedColorSwatchController = nil;


// we don't need to subclass DBMatrix to get the correct cell class because its a color cell class by default
@implementation DBColorSwatchController
+ (id)sharedColorSwatchController 
{
    if (!_sharedColorSwatchController) {
        _sharedColorSwatchController = [[DBColorSwatchController allocWithZone:[self zone]] init];
    }
    return _sharedColorSwatchController;
}

+ (NSString *) colorListDirectory 
{
	NSString *colorDir;
	NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, /* expandTilde */ YES);

	colorDir = [searchPath objectAtIndex:0];
	colorDir = [colorDir stringByAppendingString:@"/Colors/"];

	return colorDir;
}                

- (id)init 
{
    self = [self initWithWindowNibName:@"DBColorSwatches"];
    if (self) {                                 
		_list = [[[NSColorList availableColorLists] objectAtIndex:0] retain];
	
        [self setWindowFrameAutosaveName:@"DBColorSwatches"];
    }
    return self;
}

- (void)dealloc
{
	[_list release];
	
	[super dealloc];
}

- (void)awakeFromNib
{   
	[_actionPopUp setImage:[NSImage imageNamed:@"blkContextButton"]];
	[_menu setDelegate:self];
}

#pragma mark DBMatrixDataSource protocol

- (Class)cellClass
{
	return [DBColorCell class];
}

- (int)numberOfObjects
{       
	return [[_list allKeys] count];
}   

- (id)objectAtIndex:(int)index
{
	return [_list colorWithKey:[[_list allKeys] objectAtIndex:index]];
}

- (void)addObject:(id)object
{
	if(!object){ // matrix request a new object and let us define it
		[self addColor:self];
		return;
	}
//	NSLog(@"list named %@ is editable %d", [_list name], [_list isEditable]);
   	if(![_list isEditable]){
		NSString *oldName;
		NSColorList *oldList;
		
		oldName = [_list name];
		oldList = _list;
		_list = [[NSColorList alloc] initWithList:oldList name:[oldName stringByAppendingString:@" - copy"]];
		[oldList release];                                                                                   
   	}
	
	if(![object isKindOfClass:[NSColor class]]){
		NSBeep();
		return;
	}
	[_list setColor:object forKey:[object littleDescription]];
	NSString *fileName;
	fileName = [[_list name] stringByAppendingString:@".clr"];
	
	BOOL success = [_list writeToFile:[[DBColorSwatchController colorListDirectory] stringByAppendingString:fileName]];	
	
	if(!success){
		NSBeep();
	}
}

- (void)removeObject:(id)object
{
	if(![_list isEditable]){
		NSString *oldName;
		NSColorList *oldList;
		
		oldName = [_list name];
		oldList = _list;
		_list = [[NSColorList alloc] initWithList:oldList name:[oldName stringByAppendingString:@" - copy"]];
		[oldList release];                                                                                   
   	}
	
	if(![object isKindOfClass:[NSColor class]]){
		NSBeep();
		return;
	}   
	
	[_list removeColorWithKey:[_list keyWithColor:object]];
	NSString *fileName;
	fileName = [[_list name] stringByAppendingString:@".clr"];
	
	BOOL success = [_list writeToFile:[[DBColorSwatchController colorListDirectory] stringByAppendingString:fileName]];	
	
	if(!success){
		NSBeep();
	}
   	
}

- (id)readObjectFromPasteboard:(NSPasteboard *)pb;                                   
{
	return [NSColor colorFromPasteboard:pb]; 
}

- (void)writeObject:(id)object toPasteboard:(NSPasteboard *)pb
{
	[object writeToPasteboard:pb];
	
}

- (NSArray *)draggedTypes
{
	return [NSArray arrayWithObjects:NSColorPboardType,  nil];
}

- (void)dragObject:(id)object withEvent:(NSEvent *)theEvent pasteBoard:(NSPasteboard *)pboard
{
	[NSColorPanel dragColor:object withEvent:theEvent fromView:_matrix];
}
#pragma mark -

- (IBAction)addColor:(id)sender
{
	[self addObject:[[NSColorPanel sharedColorPanel] color]];
	[_matrix reloadData];
}

- (int)numberOfItemsInMenu:(NSMenu *)menu
{
	return [[NSColorList availableColorLists] count];
}

- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(int)index shouldCancel:(BOOL)shouldCancel
{
	[item setTitle:[[[NSColorList availableColorLists] objectAtIndex:index] name]];
	return YES;
}

- (IBAction)changeList:(id)sender
{
//	NSLog(@"item : %@", [sender selectedItem]);
	int index;
	int count;
	
	count = [self numberOfObjects];
	
	NSColorList *newList;
	
	index = [_menu indexOfItem:[sender selectedItem]];
	
	newList  = [[[NSColorList availableColorLists] objectAtIndex:index] retain];
   	[_list release];
	_list = newList;
	                   
	[_matrix reloadDataInRange:NSMakeRange(0,MAX(count,[self numberOfObjects]) -1 )];
}


@end
