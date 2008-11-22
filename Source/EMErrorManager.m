//
//  ErrorManager.m
//  Error Manager App
//
//  Created by Raphael Bost on 28/10/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import "EMErrorManager.h"

#import "EMErrorView.h"
#import "EMError.h"


@implementation EMErrorManager
- (id) initWithAttachedView:(NSView *)view corner:(EMCorner)c offset:(NSPoint)offset
{
	self = [super init];
	if (self != nil) {
		_offsetPoint = offset;
		_errorView = [[EMErrorView alloc] initWithView:view baseCorner:c];
		[view addSubview:_errorView positioned:NSWindowAbove relativeTo:nil]; // put it above all the other views
		//[view addSubview:_errorView];
		[_errorView setNeedsDisplay:YES]; 
		
		_timer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(closeError:) userInfo:nil repeats:NO] retain];
	}
	return self;
}


- (void) dealloc {
	[_errorView removeFromSuperview];
	[_errorView release];
	
	[_timer release];
	
	[super dealloc];
}

- (void)attachViewToNewView:(NSView *)v
{
	NSRect frame = [_errorView frame];
	BOOL flipped = [v isFlipped];
	if([_errorView baseCorner] == UpperLeftCorner || [_errorView baseCorner] == UpperRightCorner){
		if(!flipped){
			frame.origin.y -= _offsetPoint.y;
		}else{
			frame.origin.y += _offsetPoint.y;
		}	
	}else{
		if(!flipped){
			frame.origin.y += _offsetPoint.y;
		}else{
			frame.origin.y -= _offsetPoint.y;
		}	
	}   

	if([_errorView baseCorner] == UpperLeftCorner || [_errorView baseCorner] == LowerLeftCorner){
			frame.origin.x += _offsetPoint.x; 
	}else{
			frame.origin.x -= _offsetPoint.x;
	}   
	
	[_errorView setFrame:frame];
	
	[_errorView removeFromSuperview];
	[[_errorView attachedView] setNeedsDisplayInRect:frame];
	[v addSubview:_errorView positioned:NSWindowAbove relativeTo:nil]; // put it above all the other views
	[_errorView setAttachedView:v];
}

- (void)removeErrorView
{
	[_errorView removeFromSuperview];
}

- (void)postError:(EMError *)error
{   
/*	if([_timer isValid]){
		[_timer invalidate];
	}                       
*/	
	[_errorView displayError:error]; 
	
	NSRect frame = [_errorView frame];
	BOOL flipped = [[_errorView attachedView] isFlipped];
	if([_errorView baseCorner] == UpperLeftCorner || [_errorView baseCorner] == UpperRightCorner){
		if(!flipped){
			frame.origin.y -= _offsetPoint.y;
		}else{
			frame.origin.y += _offsetPoint.y;
		}	
	}else{
		if(!flipped){
			frame.origin.y += _offsetPoint.y;
		}else{
			frame.origin.y -= _offsetPoint.y;
		}	
	}   

	if([_errorView baseCorner] == UpperLeftCorner || [_errorView baseCorner] == LowerLeftCorner){
			frame.origin.x += _offsetPoint.x; 
	}else{
			frame.origin.x -= _offsetPoint.x;
	}   
	
	[_errorView setFrame:frame];
		
}

- (void)postErrorName:(NSString *)name description:(NSString *)description
{
	[self postError:[EMError errorWithName:name description:description]];
}


- (EMErrorView *)errorView
{
	return _errorView;
} 

- (NSPoint)offsetPoint
{
	return _offsetPoint;
}
- (void)setOffsetPoint:(NSPoint)newOffsetPoint
{
	_offsetPoint = newOffsetPoint;
   
 	NSRect frame = [_errorView frame];
	BOOL flipped = [[_errorView attachedView] isFlipped];
	if([_errorView baseCorner] == UpperLeftCorner || [_errorView baseCorner] == UpperRightCorner){
		if(!flipped){
			frame.origin.y -= _offsetPoint.y;
		}else{
			frame.origin.y += _offsetPoint.y;
		}	
	}else{
		if(!flipped){
			frame.origin.y += _offsetPoint.y;
		}else{
			frame.origin.y -= _offsetPoint.y;
		}	
	}   

	if([_errorView baseCorner] == UpperLeftCorner || [_errorView baseCorner] == LowerLeftCorner){
			frame.origin.x += _offsetPoint.x; 
	}else{
			frame.origin.x -= _offsetPoint.x;
	}   
	
	[_errorView setFrame:frame];

}

/*- (void)closeError:(NSTimer *)timer
{
	[self postError:nil];
}
*/

@end
