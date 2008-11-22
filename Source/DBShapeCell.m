//
//  DBShapeCell.m
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBShapeCell.h"

#import "DBShape.h"

@implementation DBShapeCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{      
	if(controlView){
		[[NSColor whiteColor] set];
		[NSBezierPath fillRect:cellFrame];		
	}
	NSAffineTransform *af, *translation, *scale;             
	NSPoint vec;
	float scaleFact;
	
	if([[self objectValue] isKindOfClass:[DBShape class]]){

		DBShape *shape;
		shape = [self objectValue];
		
		scaleFact = (cellFrame.size.width - 2.0) / [shape bounds].size.width;
		scaleFact = MIN(scaleFact,(cellFrame.size.height - 2.0) / [shape bounds].size.height);
		
		vec = [[self objectValue] translationToCenterInRect:cellFrame];
	
		af = [NSAffineTransform transform];
        translation = [NSAffineTransform transform];
        scale = [NSAffineTransform transform];

		if(scaleFact < 1.0){    
			[translation translateXBy:-[shape bounds].origin.x yBy:-[shape bounds].origin.y];
			[translation translateXBy:-[shape bounds].size.width/2 yBy:-[shape bounds].size.height/2];

			[scale scaleBy:scaleFact];                

  		}else{
	       	[translation translateXBy:-vec.x yBy:-vec.y];
		}		
    	[af appendTransform:translation];
    	[af appendTransform:scale];
	    
		if(scaleFact < 1.0){
	        translation = [NSAffineTransform transform];
			[translation translateXBy:cellFrame.size.width/2+cellFrame.origin.x yBy:cellFrame.size.height/2+cellFrame.origin.y];
	    	[af appendTransform:translation];
		}
			
		[NSGraphicsContext saveGraphicsState];
		[af concat];
		[shape drawInView:controlView rect:[shape bounds]];
		[NSGraphicsContext restoreGraphicsState];
	}                                                                
}

- (void)dealloc
{
	[_shape release];
	
	[super dealloc];
}

- (id)objectValue
{
	return _shape;
}                 

- (void)setObjectValue:(id)object
{
	if([object isKindOfClass:[DBShape class]]){
		[self setShape:object];
	}else{
		[self setShape:nil];
	}
}

- (DBShape *)shape
{
	return _shape;
}

- (void)setShape:(DBShape *)newShape
{
	[newShape retain];
	[_shape release];
	_shape = newShape;
}                           

@end
