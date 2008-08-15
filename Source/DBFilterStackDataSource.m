//
//  DBFilterStackDataSource.m
//  DrawBerry
//
//  Created by Raphael Bost on 25/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBFilterStackDataSource.h"
#import "DBFilterStack.h"
#import "ViewCell.h"
#import <QuartzCore/QuartzCore.h>

#import "DBApplicationController.h"
#import "DBLayerController.h"
#import "DBCIFilterPickerController.h"
#import "ViewCell.h"
#import "DBCILayer.h"


 
@implementation DBFilterStackDataSource
- (void)awakeFromNib
{
	[[_filtersTableView tableColumnWithIdentifier:@"Filters"] setDataCell: [[ViewCell alloc] init]];
	[[NSApp delegate] addObserver:self 
				forKeyPath:@"currentLayerController" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterStackDidChange:) name:DBFilterStackDidChangeNotification object:nil];
}
 
- (void)dealloc
{
	[_layerController removeObserver:self forKeyPath:@"selectionIndex"];
	[_layerController release];
	[[NSApp delegate] removeObserver:self forKeyPath:@"currentLayerController"];
	
	[super dealloc];
}

- (int)numberOfRowsInTableView:(NSTableView *)tv
{    
//	NSLog(@"number : %d", [[_effectStack boxes] count]);
	if(!_effectStack){
		return 0;
	}              
	
	return [[_effectStack boxes] count];
}  

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(int)row
{
	id s;
	s = [NSDictionary dictionaryWithObject:[[_effectStack boxes] objectAtIndex:row] forKey:@"View"];
    
	if(!_effectStack){
		return nil;
	}              
	
	return s;
}

- (float)tableView:(NSTableView *)tableView heightOfRow:(int)row
{
	float height = 100.0;

	height = [(NSView *)[[_effectStack boxes] objectAtIndex:row] frame].size.height;

	
	if([[[tableView tableColumnWithIdentifier:@"Effects"] dataCellForRow:row] collapsed]){
    	return 20.0;
	}
	return height;
}

- (IBAction)add:(id)sender
{
	[_effectStack addFilter:sender];
	[[_layerController selectedLayer] updateRenderInView:nil];
	[[[NSApp delegate] currentDrawingView] setNeedsDisplay:YES];
	[_filtersTableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	id selectedLayer;
	
	if([keyPath isEqualToString:@"currentLayerController"]){
	
		if(_layerController){
			[_layerController removeObserver:self forKeyPath:@"selectionIndex"];
		}
		[_layerController release];
		_layerController = [[[NSApp delegate] currentLayerController] retain];
        
		if(_layerController){
			[_layerController addObserver:self 
							   forKeyPath:@"selectionIndex" 
							      options:NSKeyValueObservingOptionNew 
							      context:nil];
		}
		
		selectedLayer = [_layerController selectedLayer];
		
		if([selectedLayer isKindOfClass:[DBCILayer class]]){
			_effectStack = [selectedLayer filterStack];
		}else{
			_effectStack = nil;
		}
		[[_filtersTableView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[_filtersTableView reloadData];
		
	}else if([keyPath isEqualToString:@"selectionIndex"]){
		
		selectedLayer = [_layerController selectedLayer];
		
		if([selectedLayer isKindOfClass:[DBCILayer class]]){
			_effectStack = [selectedLayer filterStack];
		}else{
			_effectStack = nil;
		}
		[[_filtersTableView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[_filtersTableView reloadData];
	}
}

- (void)filterStackDidChange:(NSNotification *)note
{
	if([note object] == _effectStack){
		[_filtersTableView reloadData];
		[[_filtersTableView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	return YES;
}
@end
