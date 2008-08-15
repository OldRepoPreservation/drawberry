//
//  EMErrorView.m
//  Error Manager App
//
//  Created by Raphael Bost on 28/10/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import "EMErrorView.h"

#import "EMError.h"

#import "NSBezierPath+Extensions.h"


#define EMMImageMargin 2
@interface EMErrorView (Private)
- (void)_recalculateFrame;
- (void)resetTrackingRect;
- (void)clearTrackingRect;
@end

@implementation EMErrorView
- (id)initWithView:(NSView *)v baseCorner:(EMCorner)baseCorner
{
	self = [super initWithFrame:NSZeroRect];
    if (self) {
        // Initialization code here.
		_attachedView = v;
		_baseCorner = baseCorner;
		
		_topMargin = 6.0;
		_verticalMargin = 7.0;
		_timeout = 2.0; // 2 seconds for orginal timeout
		
		[self setBackgroundColor:[NSColor clearColor]];
		
		_closeImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"cancel"]];
		[_closeImage setScalesWhenResized:YES];
		[_closeImage setSize:NSMakeSize(12.0,12.0)];
		_closeImagePressed = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"cancel_pressed"]];
		[_closeImagePressed setScalesWhenResized:YES];
		[_closeImagePressed setSize:NSMakeSize(12.0,12.0)];
		_imageRect.size = [_closeImage size];
		
		_mouseOver = NO;
		_closePressed = NO;
		_rolloverTrackingRectTag = 0;
		
		[self _recalculateFrame];
    }
    return self;
}

- (void) dealloc 
{
	[_titleAttributes release];
	[_descriptionAttributes release];
	
	[_closeImage release];
	[_closeImagePressed release];
	
	[_currentError release];
	
	[_timeoutTimer invalidate];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect 
{
    // Drawing code here.
   	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds],2,2) cornerRadius:5.0];
    [path setLineWidth:2.0];

	[_backgroundColor set];
	[path fill];
	
	float height = [self frame].size.height;
	NSPoint point;
	NSSize size;
	
	//add a margin at top
	height -= _topMargin;
	size = [[_currentError name] sizeWithAttributes:_titleAttributes];
	height -= size.height;
	
	point.y = height;
	if (_baseCorner == LowerRightCorner || _baseCorner == UpperRightCorner) {
		// align at right
		point.x = [self frame].size.width - (size.width + _verticalMargin);
	}else {
		point.x = _verticalMargin;
	}

	[[_currentError name] drawAtPoint:point withAttributes:_titleAttributes];
	
	height -= _topMargin/2.0;
	size = [[_currentError description] sizeWithAttributes:_descriptionAttributes];
	height -= size.height;

	point.y = height;

	if (_baseCorner == LowerRightCorner || _baseCorner == UpperRightCorner) {
		// align at right
		point.x = [self frame].size.width - (size.width + _verticalMargin);
	}
	[[_currentError description] drawAtPoint:point withAttributes:_descriptionAttributes];

	[[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] set];
	[path stroke];

	if (_mouseOver && ([_currentError name] || [_currentError description])) {
		if (_closePressed) {
			[_closeImagePressed compositeToPoint:_imageRect.origin operation:NSCompositeSourceOver];
		}else {
			[_closeImage compositeToPoint:_imageRect.origin operation:NSCompositeSourceOver];
		}
	}
	
}

#pragma mark Displaying error

- (void)displayError:(EMError *)e
{
	[_currentError release];
	_currentError = [e retain];
	
	// resize view
	NSRect oldFrame = [self frame];
	[self _recalculateFrame];
	
	[_attachedView setNeedsDisplayInRect:oldFrame];
	
	[self setNeedsDisplay:YES];
	
	//setup timeout timer
	[_timeoutTimer invalidate];
	[_timeoutTimer release];
	_timeoutTimer = nil;
	
	if (e) {
		_timeoutTimer = [[NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(timeout:) userInfo:nil repeats:NO] retain];
	}
}

- (void)_recalculateFrame
{
	double height = 0.0, width;
	NSSize size;
	NSPoint point;
	
	height += _topMargin;
	size = [[_currentError name] sizeWithAttributes:_titleAttributes];
	
	width = size.width;
	height += size.height;
	
	height += _topMargin;
	size = [[_currentError description] sizeWithAttributes:_descriptionAttributes];
	width = MAX(size.width,width) + 2*_verticalMargin;
	height += size.height;
	
	height += _topMargin;

	if ([_attachedView isFlipped]) {
		NSRect bounds = [_attachedView bounds];
		if (_baseCorner == UpperLeftCorner) {
			point = NSMakePoint(NSMinX(bounds),NSMinY(bounds));
		}else if (_baseCorner == UpperRightCorner) {
			point = NSMakePoint(NSMaxX(bounds),NSMinY(bounds));
			point.x-=width;			
		}else if (_baseCorner == LowerLeftCorner) {
			point = NSMakePoint(NSMinX(bounds),NSMaxY(bounds));
			
			point.y -= height;
		}else if (_baseCorner == LowerRightCorner) {
			point = NSMakePoint(NSMaxX(bounds),NSMaxY(bounds));
			
			point.y -= height;
			point.x-=width;			
		}
	}else if (![_attachedView isFlipped]) {
		NSRect bounds = [_attachedView bounds];
		if (_baseCorner == LowerLeftCorner) {
			point = NSMakePoint(NSMinX(bounds),NSMinY(bounds));
			
		}else if (_baseCorner == LowerRightCorner) {
			point = NSMakePoint(NSMaxX(bounds),NSMinY(bounds));	
			
			point.x-=width;
		}else if (_baseCorner ==  UpperLeftCorner) {
			point = NSMakePoint(NSMinX(bounds),NSMaxY(bounds));

			point.y -= height;
		}else if (_baseCorner ==  UpperRightCorner) {
			point = NSMakePoint(NSMaxX(bounds),NSMaxY(bounds));
			
			point.y -= height;
			point.x -= width;
		}
	}
	
	NSRect frame;
//	NSPoint offsetPoint = 
	frame.origin = point;
	frame.size = NSMakeSize(width,height);
	 	
	// put the close image in the opposite corner
	if (_baseCorner == LowerLeftCorner) {
		_imageRect.origin = NSMakePoint(frame.size.width-_imageRect.size.width-EMMImageMargin,frame.size.height - _imageRect.size.height-EMMImageMargin);
	}else if (_baseCorner == LowerRightCorner) {
		_imageRect.origin = NSMakePoint(EMMImageMargin,frame.size.height - _imageRect.size.height-EMMImageMargin);
	}else if (_baseCorner ==  UpperLeftCorner) {
		_imageRect.origin = NSMakePoint(frame.size.width-_imageRect.size.width-EMMImageMargin,EMMImageMargin);
	}else if (_baseCorner ==  UpperRightCorner) {
		_imageRect.origin = NSMakePoint(EMMImageMargin,EMMImageMargin);
	}
	
	if (![_currentError name] && ![_currentError description]) {
		frame.size = NSZeroSize;
	}
	
	[self setFrame:frame];
	[self resetTrackingRect];

}

#pragma mark Accessors

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	
	if (_baseCorner == LowerLeftCorner) {
		_imageRect.origin = NSMakePoint(frame.size.width-_imageRect.size.width-EMMImageMargin,frame.size.height - _imageRect.size.height-EMMImageMargin);
	}else if (_baseCorner == LowerRightCorner) {
		_imageRect.origin = NSMakePoint(EMMImageMargin,frame.size.height - _imageRect.size.height-EMMImageMargin);
	}else if (_baseCorner ==  UpperLeftCorner) {
		_imageRect.origin = NSMakePoint(frame.size.width-_imageRect.size.width-EMMImageMargin,EMMImageMargin);
	}else if (_baseCorner ==  UpperRightCorner) {
		_imageRect.origin = NSMakePoint(EMMImageMargin,EMMImageMargin);
	}
	
}

- (NSTimeInterval)timeout {return _timeout;}
- (void)setTimeout:(NSTimeInterval)t
{
	_timeout = t;
}

- (NSDictionary *)titleAttributes { return _titleAttributes; }
- (void)setTitleAttributes:(NSDictionary *)d
{
	[_titleAttributes release];
	_titleAttributes = [d copy];
}

- (NSDictionary *)descriptionAttributes {return _descriptionAttributes; }
- (void)setDescriptionAttributes:(NSDictionary *)d
{
	[_descriptionAttributes release];
	_descriptionAttributes = [d copy];
}

- (EMCorner)baseCorner { return _baseCorner; }
- (void)setBaseCorner:(EMCorner)corner 
{
	[_attachedView setNeedsDisplayInRect:[self frame]];
	_baseCorner = corner%4;
	[self _recalculateFrame];
}

- (NSColor *)backgroundColor { return _backgroundColor; }
- (void)setBackgroundColor:(NSColor *)color
{
	[_backgroundColor release];
	_backgroundColor = [color retain];
	
	[self setNeedsDisplay:YES];
}

- (NSImage *)closeImage { return _closeImage; }
- (void)setCloseImage:(NSImage *)image
{
	[_closeImage release];
	_closeImage = [image retain];
}

- (NSImage *)closeImagePressed { return _closeImagePressed; }
- (void)setCloseImagePressed:(NSImage *)image
{
	[_closeImagePressed release];
	_closeImagePressed = [image retain];
}

- (NSView *)attachedView { return _attachedView; }
- (void)setAttachedView:(NSView *)view
{
	_attachedView = view;
	
	[self setNeedsDisplay:YES];
}

#pragma mark Tracking Rect for Rollover
- (void)resetTrackingRect
{
	[self clearTrackingRect];
	_rolloverTrackingRectTag = [self addTrackingRect:[self visibleRect]
											   owner:self 
											userData:NULL
										assumeInside:NO];
}

- (void)clearTrackingRect
{
	if (_rolloverTrackingRectTag > 0) {
		[self removeTrackingRect:_rolloverTrackingRectTag];
		_rolloverTrackingRectTag = 0;
	}
}

- (void)resetCursorRects
{
	[super resetCursorRects];
	[self resetTrackingRect];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	_mouseOver = YES;
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	_mouseOver = NO;
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil],_imageRect)) {
		_closePressed = YES;
	}else {
		_closePressed = NO;
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	BOOL previousPressedState = _closePressed;
	if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil],_imageRect)) {
		_closePressed = YES;
	}else {
		_closePressed = NO;
	}	
	
	if (previousPressedState != _closePressed) {
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (_closePressed) {
		_closePressed = NO;
		_mouseOver = NO;
		[self displayError:nil];
	}

}

#pragma mark Callback

- (void)timeout:(NSTimer *)timer
{
	[self displayError:nil];
}
@end
