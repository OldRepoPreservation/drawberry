//
//  DBTemplateManager.m
//  DrawBerry
//
//  Created by Raphael Bost on 28/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DBTemplateManager.h"

static DBTemplateManager *__sharedTemplateManager = nil;

NSString *DBTemplateMenuDidChangeNotification = @"DBTemplateMenuDidChangeNotification";

@implementation DBTemplateManager
+ (id)sharedTemplateManager
{
	if(!__sharedTemplateManager){
		__sharedTemplateManager = [[DBTemplateManager allocWithZone:[self zone]] init];
	}
	
	return __sharedTemplateManager;
}

+ (NSString *)applicationSupportFolder 
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"DrawBerry"];
}

- (id)init
{
	self = [super init];
	
	_customTemplates = nil;
	_builtInTemplates = nil;
	_templatesMenu = nil;
	
	[self loadBuiltInTemplates];
	[self loadCustomTemplates];
	[self updateTemplatesMenu];
	
	return self;
}

- (void)dealloc
{
	//[self writeCustomTemplates]; // useless
	
	[_customTemplates release];
	[_builtInTemplates release];
	[_templatesMenu release];
	
	[super dealloc];
}

- (void)loadBuiltInTemplates
{
	_builtInTemplates = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Templates" ofType:@"plist"]];
}

- (void)loadCustomTemplates
{
	[_customTemplates release];
	_customTemplates = nil;
	
	NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
	NSString *path;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [DBTemplateManager applicationSupportFolder];
    
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
		_customTemplates = [[NSMutableArray alloc] init];
		return;
    }
	
	path = [applicationSupportFolder stringByAppendingPathComponent:@"Templates.plist"];

	if ( ![fileManager fileExistsAtPath:path isDirectory:NULL] ) {
		_customTemplates = [[NSMutableArray alloc] init];
		return;
    }
	
	_customTemplates = [[NSMutableArray alloc] initWithContentsOfFile:path];
	
	if(!_customTemplates){
		NSLog(@"cannot read custom templates file");
		_customTemplates = [[NSMutableArray alloc] init];
	}
}

- (void)writeCustomTemplates
{
	if(!_customTemplates)
		return;
	
	NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
	NSString *path;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [DBTemplateManager applicationSupportFolder];
    
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
	
	path = [applicationSupportFolder stringByAppendingPathComponent:@"Templates.plist"];
	
	if(![_customTemplates writeToFile:path atomically:NO]){
		NSBeep();
		NSLog(@"error when writing templates %@",_customTemplates);
	}
}

- (NSMutableArray *)customTemplates
{
	return _customTemplates;
}

- (void)setCustomTemplate:(NSArray *)templates
{
	id newTemplates;
	
	newTemplates = [templates mutableCopy];
	[_customTemplates release];
	_customTemplates = newTemplates;
	
	[self writeCustomTemplates];
}

- (NSDictionary *)templateForTag:(int)tag
{
	NSArray *array;
	if(tag < 100){
		array = _builtInTemplates;
	}else {
		array = _customTemplates;
		tag -= 100;
	}
	
	if(tag >= 0 && tag < [array count]){
		return [array objectAtIndex:tag];
	}
	
	return nil;
}

- (NSSize)sizeForTemplateTag:(int)tag
{
	NSDictionary *template;
	
	template = [self templateForTag:tag];
	
	if(template){
		return NSSizeFromString([template objectForKey:@"Size"]);		
	}

	return NSZeroSize;
}

- (NSDictionary *)customTemplateForTag:(int)tag
{
	return [self templateForTag:tag+100];
}

- (NSDictionary *)builtInTemplateForTag:(int)tag
{
	return [self templateForTag:tag];
}

- (void)setName:(NSString *)name forCustomTemplateAtTag:(int)tag
{
	if(tag >= 0 && tag < [_customTemplates count]){
		NSDictionary *template, *newTemplate;
	
		template = [self customTemplateForTag:tag];
		newTemplate = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"Name",[template objectForKey:@"Size"],@"Size",nil];
		
		[_customTemplates replaceObjectAtIndex:tag withObject:newTemplate];
		
		[newTemplate release];
		
		[self writeCustomTemplates];
		[self updateTemplatesMenu];
	}
}

- (void)setSize:(NSSize)size forCustomTemplateAtTag:(int)tag
{
	if(tag >= 0 && tag < [_customTemplates count]){
		NSDictionary *template, *newTemplate;
		
		template = [self customTemplateForTag:tag];
		newTemplate = [[NSDictionary alloc] initWithObjectsAndKeys:[template objectForKey:@"Name"],@"Name",size,@"Size",nil];
		
		[_customTemplates replaceObjectAtIndex:tag withObject:newTemplate];
		
		[newTemplate release];
		
		[self writeCustomTemplates];
		[self updateTemplatesMenu];
	}
}

- (void)setWidth:(float)width forCustomTemplateAtTag:(int)tag
{
	if(tag >= 0 && tag < [_customTemplates count]){
		NSSize size;
		
		size = NSSizeFromString( [[self customTemplateForTag:tag] objectForKey:@"Size"]);
		size.width = width;
		
		[self setSize:size forCustomTemplateAtTag:tag];
	}
}

- (void)setHeight:(float)height forCustomTemplateAtTag:(int)tag
{
	if(tag >= 0 && tag < [_customTemplates count]){
		NSSize size;
		
		size = NSSizeFromString( [[self customTemplateForTag:tag] objectForKey:@"Size"]);
		size.height = height;
		
		[self setSize:size forCustomTemplateAtTag:tag];
	}
}

- (void)addUntitledTemplate
{
	[self addCustomTemplateWithName:NSLocalizedString(@"Untitled",nil) size:NSMakeSize(100.f, 100.f)];
}

- (void)addCustomTemplateWithName:(NSString *)name size:(NSSize)size
{
	NSDictionary *template;
	
	template = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"Name",NSStringFromSize(size),@"Size",nil];
	
	[_customTemplates addObject:template];
	
	[template release];
	
	[self writeCustomTemplates];
	[self updateTemplatesMenu];
}

- (void)removeCustomTemplateWithTag:(int)tag
{
	if(tag >=0 && tag < [_customTemplates count])
	{
		[_customTemplates removeObjectAtIndex:tag];
		[self writeCustomTemplates];
		[self updateTemplatesMenu];
	}
}

- (void)updateTemplatesMenu
{
	[_templatesMenu release];
	_templatesMenu = [[NSMenu alloc] initWithTitle:@"Templates"];
	
	int i;
	NSEnumerator *e;
	NSDictionary *template;
	NSMenuItem *item;
	
	i = 0;
	e = [_builtInTemplates objectEnumerator];
	
	while ((template = [e nextObject])) {
		item = [[NSMenuItem alloc] initWithTitle:[template objectForKey:@"Name"] action:nil keyEquivalent:@""];
		[item setTag:i];
		i++;
		
		[_templatesMenu addItem:item];
		[item release];
	}
	
	[_templatesMenu addItem:[NSMenuItem separatorItem]];
	
	i = 0;
	e = [_customTemplates objectEnumerator];
	
	while ((template = [e nextObject])) {
		item = [[NSMenuItem alloc] initWithTitle:[template objectForKey:@"Name"] action:nil keyEquivalent:@""];
		[item setTag:100+i];
		i++;
		
		[_templatesMenu addItem:item];
		[item release];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DBTemplateMenuDidChangeNotification object:self];
}

- (NSMenu *)templatesMenu
{
	return _templatesMenu;
}
@end
