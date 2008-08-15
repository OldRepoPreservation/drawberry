//
//  DBImageView.m
//  DrawBerry
//
//  Created by Raphael Bost on 22/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBImageView.h"


@implementation DBImageView

- (void)setEditable:(BOOL)flag
{
	[super setEditable:YES];
}

- (IBAction)chooseFile:(id)sender
{
	NSOpenPanel *op;
	int result;
	
	op = [NSOpenPanel openPanel];
	
	result = [op runModalForTypes:[NSImage imageFileTypes]];
	
	if(result == NSOKButton){
		[self setValue:[[[NSImage alloc] initByReferencingFile:[[op filenames] objectAtIndex:0] ] autorelease] forKey:@"image"];
	}
}

@end
