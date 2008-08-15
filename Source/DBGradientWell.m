//
//  DBGradientWell.m
//  DrawBerry
//
//  Created by Raphael Bost on 25/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBGradientWell.h"

#import "DBGradientCell.h"

@implementation DBGradientWell
+ (Class)cellClass
{
	return [DBGradientCell class];
}   

+ (void)initialize
{
	[self exposeBinding:@"gradient"];
	[self exposeBinding:@"value"];
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(gradientPanelWillClose:) 
												 name:NSWindowWillCloseNotification 
											   object:[[GCGradientPanel sharedGradientPanel] window]];
	            
	return self;
}
     
- (void)mouseDown:(NSEvent *)theEvent
{
//	NSLog(@"down");
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[[self cell] setHighlighted:(![[self cell] isHighlighted])];
	[self setNeedsDisplay:YES]; 
	
	if([[self cell] isHighlighted]){
		[[[GCGradientPanel sharedGradientPanel] window] makeKeyAndOrderFront:self];
        
		[[GCGradientPanel sharedGradientPanel] setGradient:[self gradient]];
		[[GCGradientPanel sharedGradientPanel] setTarget:self];
		[[GCGradientPanel sharedGradientPanel] setAction:@selector(gradientChanged:)];
	}else{
		[[GCGradientPanel sharedGradientPanel] setTarget:nil];
	}
}

- (void)gradientPanelWillClose:(NSNotification *)note
{
	[[self cell] setHighlighted:NO];
	[self setNeedsDisplay:YES];
	
	[[GCGradientPanel sharedGradientPanel] setTarget:nil];

	[self setGradient:[[GCGradientPanel sharedGradientPanel] gradient]];
}

- (void)gradientChanged:(id)object
{ 
	[self setGradient:[[GCGradientPanel sharedGradientPanel] gradient]];
}

- (GCGradient *)gradient
{
	return [[self cell] gradient];
}

- (void)setGradient:(GCGradient *)newGradient
{   
	[self willChangeValueForKey:@"gradient"];
	[[self cell] setGradient:newGradient];
	[self setNeedsDisplay:YES];
	[self didChangeValueForKey:@"gradient"];
} 

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)mouseDownEvent
{
	return YES;
}

- (id)objectValue
{
	return [self gradient];
}

- (void)setObjectValue:(id)newObjectValue
{
	[self setGradient:newObjectValue];
}
@end
