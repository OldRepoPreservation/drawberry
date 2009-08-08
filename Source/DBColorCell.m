//
//  DBColorCell.m
//  DBColorSwatchApp
//
//  Created by Raphael Bost on 08/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBColorCell.h"

#import "DBMatrix.h"


@implementation DBColorCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{       
	
	if(_color){
		[_color set];
		[NSBezierPath fillRect:cellFrame];
	}// else{
	// 		[[NSColor greenColor] set];
	// 		[NSBezierPath fillRect:cellFrame];
	// 	}
	// //	[[NSColor redColor] set];
//	[NSBezierPath fillRect:NSInsetRect(cellFrame,1.0,1.0)];
	
	if([controlView isKindOfClass:[DBMatrix class]] && [(DBMatrix *)controlView cellUnderMouse] == self){
		//[[NSColor controlHighlightColor] set];
		[[_color highlightWithLevel:0.5] set];
		
//		[NSBezierPath strokeRect:NSInsetRect(cellFrame, -0.5, -0.5)];
		[NSBezierPath strokeRect:NSInsetRect(cellFrame, 0.5, 0.5)];
	}
	
}

- (void)dealloc
{	
	[_color release];
	
	[super dealloc];
}                    

- (id)objectValue
{
	return _color;
}                 

- (void)setObjectValue:(id)object
{                          
	if([object isKindOfClass:[NSColor class]]){
		[self setColor:object];
	}else{
		[self setColor:nil];
	}
}                           

- (NSColor *)color
{
	return _color;
}

- (void)setColor:(NSColor *)newColor
{               
	[newColor retain];
	[_color release];
	_color = newColor;
}
@end
