//
//  DBFill.m
//  DrawBerry
//
//  Created by Raphael Bost on 20/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBFill.h"

#import "DBShape.h"


static NSLayoutManager*		sharedDrawingLayoutManager()
{
    // This method returns an NSLayoutManager that can be used to draw the contents of a GCTextShape.
	// The same layout manager is used for all instances of the class
	
    static NSLayoutManager *sharedLM = nil;
    
	if ( sharedLM == nil )
	{
        NSTextContainer*	tc = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
		NSTextView*			tv = [[NSTextView alloc] initWithFrame:NSZeroRect];
        
        sharedLM = [[NSLayoutManager alloc] init];
		
		[tc setTextView:tv];
		[tv release];
		
        [tc setWidthTracksTextView:NO];
        [tc setHeightTracksTextView:NO];
        [sharedLM addTextContainer:tc];
        [tc release];
		
		[sharedLM setUsesScreenFonts:NO];
    }
    return sharedLM;
}

@implementation DBFill

#pragma mark Initializations & Co
+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObject:@"fillMode"] triggerChangeNotificationsForDependentKey:@"needsColor"];
	[self setKeys:[NSArray arrayWithObject:@"fillMode"] triggerChangeNotificationsForDependentKey:@"needsImage"];
	[self setKeys:[NSArray arrayWithObject:@"fillMode"] triggerChangeNotificationsForDependentKey:@"needsGradient"];
}

- (id)initWithShape:(DBShape *)shape
{
	self = [super init];
	                                           
	_shape = shape;
	_fillMode = 0;
	_imageFillMode = 100;
	_fillColor = [[NSColor whiteColor] retain];            
	_fillImage = nil;

	_gradient = [[GCGradient gradientWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]] retain];
	
	[self resetImageDrawPoint];
	
	return self;
}

- (void)dealloc
{
	[_fillColor release];
	[_fillImage release];
	[_fillCache release];
	[_maskImage release];
	[_gradient release];
	//[_text release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	DBFill *fill = [[DBFill alloc] init];
	
	[fill setFillMode:[self fillMode]];
	[fill setFillMode:[self fillMode]];

	[fill setFillColor:[[[self fillColor] copy] autorelease]];
	[fill setFillImage:[[[self fillImage] copy] autorelease]];
	[fill setGradient:[[[self gradient] copy] autorelease]];

	[fill setImageDrawPoint:[self imageDrawPoint]];
	[fill setImageCenterPoint:[self imageCenterPoint]];
	 	
	return fill;
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];                     
	
	_fillMode = [decoder decodeIntForKey:@"Fill Mode"];            
	_imageFillMode = [decoder decodeIntForKey:@"Image Fill Mode"];            
	_fillColor = [[decoder decodeObjectForKey:@"Fill Color"] retain]; 
//	_fillImage = [[decoder decodeObjectForKey:@"Fill Image"] retain]; 
	_gradient = [[decoder decodeObjectForKey:@"Gradient"] retain]; 
	//_text = [[decoder decodeObjectForKey:@"Text"] retain];         


	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:_fillMode forKey:@"Fill Mode"];
	[encoder encodeInt:_imageFillMode forKey:@"Image Fill Mode"]; 
	[encoder encodeObject:_fillColor forKey:@"Fill Color"];
	[encoder encodeObject:_fillImage forKey:@"Fill Image"];
	[encoder encodeObject:_gradient forKey:@"Gradient"];
	//[encoder encodeObject:_text forKey:@"Text"];
}

#pragma mark Updating and filling
/*- (void) drawText                         
{
	NSSize osize = [_shape bounds].size;
	
	if ([_text length] > 0)
	{
		NSTextStorage *contents = [[NSTextStorage alloc] initWithAttributedString:_text];
		
		NSLayoutManager *lm = sharedDrawingLayoutManager();
		NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];

		NSRange		glyphRange;
		NSRange		grange;
//		NSRect		frag;

		
		NSAffineTransform *af = [NSAffineTransform transform];
		NSAffineTransform *translate = [NSAffineTransform transform];
		NSAffineTransform *rotate = [NSAffineTransform transform];
//		NSPoint originPoint = [_shape bounds].origin;
 		NSPoint textOrigin;

 		[rotate rotateByDegrees:[_shape rotation]];
		[translate translateXBy:[_shape rotationCenter].x yBy:[_shape rotationCenter].y];

		[af appendTransform:rotate];
		[af appendTransform:translate];
		
		[NSGraphicsContext saveGraphicsState];
		[af concat];

		[tc setContainerSize:osize];
		[contents addLayoutManager:lm];

		// Force layout of the text and find out how much of it fits in the container.

		glyphRange = [lm glyphRangeForTextContainer:tc];

		// because of the object transform applied, draw the text at the origin

		if (glyphRange.length > 0)
		{
			grange = glyphRange;

			//NSPoint textOrigin = [self textOriginForSize:textSize objectSize:osize];

			textOrigin = NSZeroPoint;
			textOrigin.x = - ([_shape bounds].size.width)/2;
			switch(_vertPos)
			{
				case 0:
 					textOrigin.y = -([_shape bounds].size.height)/2;
   					break;

				case 1:
					break;

				case 2:
					textOrigin.y = [_shape bounds].size.height/2;
					break;
			}

			[lm drawGlyphsForGlyphRange:grange atPoint:textOrigin];
		}
		[NSGraphicsContext restoreGraphicsState];
		[contents release];
	}
}
*/
- (void)fillPath:(NSBezierPath *)path
{
	if(_fillMode == DBColorFillMode){
		[_fillColor set];
		[path fill];
	}else if(_fillMode == DBImageFillMode){
		[_fillCache drawAtPoint:[_shape bounds].origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}else if(_fillMode == DBGradientFillMode){
		[_gradient fillPath:path];
//		[_gradient fillPath:path centreOffset:NSMakePoint(100,100)];
//		[_gradient fillPath:path startingAtPoint:NSMakePoint(300,300) startRadius:10.0 endingAtPoint:_imageDrawPoint endRadius:120];
	}
	
//	[[[_text layoutManagers] objectAtIndex:0] drawGlyphsForGlyphRange:NSMakeRange(0,[_text length]) atPoint:[_shape bounds].origin];
	  
//  	[self drawText];                      	
} 
  
- (void)updateFillForPath:(NSBezierPath *)path
{
/*	[_fillCache release];
	_fillCache = nil;
*/	                           
	if(!_fillImage)
		return;
	
	if(!_fillCache){
		_fillCache = [[NSImage alloc] initWithSize:[_shape bounds].size];
//		_maskImage = [[NSImage alloc] initWithSize:[_shape bounds].size];
		[_fillCache setScalesWhenResized:NO];
//		[_maskImage setScalesWhenResized:NO];
	}else if(!NSEqualSizes([_shape bounds].size, [_fillCache size])){
		[_fillCache release];
		_fillCache = [[NSImage alloc] initWithSize:[_shape bounds].size];
//		[_fillCache recache];
		[_fillCache setSize:[_shape bounds].size];

	}else{
			[_fillCache release];
			_fillCache = [[NSImage alloc] initWithSize:[_shape bounds].size];
//			[_fillCache setSize:[_shape bounds].size];	
	}
	
	[_fillImage setFlipped:YES];
	
	NSBezierPath *pathMask = path;
	NSSize originalSize = [_fillImage size];
	NSSize newSize;
	NSPoint drawPoint;
	NSAffineTransform *at = [NSAffineTransform transform];
	
	
	newSize = NSZeroSize;
	drawPoint = NSZeroPoint;
	
	if(_imageFillMode == DBStretchMode){
		newSize = [_shape bounds].size;
	}else if(_imageFillMode == DBFillPathMode){
		float multiplicationFactor;
		newSize = [_shape bounds].size;
		
		multiplicationFactor = MAX(newSize.width/originalSize.width, newSize.height/originalSize.height);
		
		newSize.width = originalSize.width*multiplicationFactor;
		newSize.height = originalSize.height*multiplicationFactor;
   	}else if(_imageFillMode == DBDrawMode){
		newSize = originalSize;
		newSize.width *= [_shape zoom];
		newSize.height *= [_shape zoom];
   	}
		
	drawPoint.x = floor(_imageDrawPoint.x*[_shape zoom] - newSize.width/2);
	drawPoint.y = floor(_imageDrawPoint.y*[_shape zoom] - newSize.height/2);

	[at translateXBy:-[_shape bounds].origin.x yBy:-[_shape bounds].origin.y];
	
	_maskImage = [[NSImage alloc] initWithSize:[_shape bounds].size];
	
	// create the mask 
	[_maskImage recache];
	[_maskImage lockFocus];
//	[[NSColor redColor] set];
//	[NSBezierPath fillRect:NSMakeRect(0, 0, [_maskImage size].width, [_maskImage size].height)];
  
	
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:NSMakeRect(drawPoint.x, drawPoint.y, newSize.width, newSize.height)];
	
	[_maskImage unlockFocus];
	
	[_fillCache recache];
	
	[_fillCache lockFocus];
	
	[[NSColor clearColor] set];
	[NSBezierPath fillRect:NSMakeRect(0, 0, [_fillCache size].width, [_fillCache size].height)];             
  
	// fill with the mask (the path)...
	
	[[NSColor blackColor] set];
	[at concat];
	[pathMask fill];
	[at invert];
	[at concat];	

	// ... cut the mask to fit with the image bounds ... 
	[_maskImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	
	// ... and then fill with the image
	[_fillImage setSize:newSize];
	[_fillImage drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	[_fillImage setSize:originalSize];
	          
	[_fillCache unlockFocus];
	
	[_maskImage release];
	_maskImage = nil;
	
	[_fillImage setFlipped:NO];
}

- (void)resetImageDrawPoint
{
/*	if(_imageFillMode == DBStretchMode){
		_imageDrawPoint.x = ([_shape bounds].size.width)/2;
		_imageDrawPoint.y = ([_shape bounds].size.height)/2;
	}else if(_imageFillMode == DBFillPathMode ){	
		_imageDrawPoint.x = ([_shape bounds].size.width)/2;
		_imageDrawPoint.y = ([_shape bounds].size.height)/2;
	}
*/	
	_imageDrawPoint.x = ([_shape bounds].size.width/[_shape zoom])/2;
	_imageDrawPoint.y = ([_shape bounds].size.height/[_shape zoom])/2;	
}   

- (void)resizeFillFromSize:(NSSize)oldSize toSize:(NSSize)newSize
{
	float multiplicationFactor;
	
	multiplicationFactor = newSize.width/oldSize.width;
   	_imageDrawPoint.x *= multiplicationFactor;
	multiplicationFactor = newSize.height/oldSize.height;
   	_imageDrawPoint.y *= multiplicationFactor;
	
//	[_textContainer setContainerSize:[_shape bounds].size];
}
 
#pragma mark Accessors

- (int)fillMode
{
	return _fillMode;
}

- (void)setFillMode:(int)newFillMode
{
	_fillMode = newFillMode;
	
	if(_fillMode == DBImageFillMode)
		[self resetImageDrawPoint];
	
	[_shape strokeUpdated];
}

- (int)imageFillMode
{
	return _imageFillMode;
}

- (void)setImageFillMode:(int)newImageFillMode
{
	_imageFillMode = newImageFillMode;
	
	[self resetImageDrawPoint];
	
	[_shape strokeUpdated];	
}

- (BOOL)needsColor
{
	return (_fillMode == DBColorFillMode);
}   

- (BOOL)needsImage
{
	return (_fillMode == DBImageFillMode);
}   

- (BOOL)needsGradient
{
	return (_fillMode == DBGradientFillMode);
}

- (NSColor *)fillColor
{
	return _fillColor;
}

- (void)setFillColor:(NSColor *)newFillColor
{
	[newFillColor retain];
	[_fillColor release];
	_fillColor = newFillColor;
	[_shape strokeUpdated];
}

- (NSImage *)fillImage
{
	return _fillImage;
}

- (void)setFillImage:(NSImage *)newFillImage
{
	[newFillImage retain];
	[_fillImage release];
	_fillImage = newFillImage;
	
	[self resetImageDrawPoint];
	[_shape strokeUpdated];
}

- (GCGradient *)gradient
{
	return _gradient;
}

- (void)setGradient:(GCGradient *)newGradient
{
	[newGradient retain];
	[_gradient release];
	_gradient = newGradient;
	
   	[_shape strokeUpdated];
}
 

- (NSPoint)imageDrawPoint
{
	return _imageDrawPoint;
}

- (void)setImageDrawPoint:(NSPoint)newImageDrawPoint
{
	_imageDrawPoint = newImageDrawPoint;
	
//	if(_fillMode == DBImageFillMode)
   	[_shape strokeUpdated];
}

- (NSPoint)imageCenterPoint
{
	return NSMakePoint(_imageDrawPoint.x - [_fillImage size].width/2, _imageDrawPoint.y - [_fillImage size].height/2);
}

- (void)setImageCenterPoint:(NSPoint)newImageCenterPoint
{
	[self setImageDrawPoint:NSMakePoint(newImageCenterPoint.x + [_fillImage size].width/2, newImageCenterPoint.y + [_fillImage size].height/2)];
}

- (DBShape *)shape
{
	return _shape;
}

- (void)setShape:(DBShape *)newShape
{
	[_shape setStroke:nil];
	_shape = newShape;
   	[_shape strokeUpdated];
} 

/* - (NSAttributedString *)text
{
	return _text;
}

- (void)setText:(NSAttributedString *)newText
{
	[newText retain];
	[_text release];
	_text = newText;
	[_shape strokeUpdated];
}

- (int)textVerticalPositon
{
	return _vertPos;
}

- (void)setTextVerticalPositon:(int)newTextVerticalPositon
{
	_vertPos = newTextVerticalPositon;
	[_shape strokeUpdated];
}

- (NSTextAlignment)textAlignment
{
	return _textAlignment;
}

- (void)setTextAlignment:(NSTextAlignment)newTextAlignment
{
	_textAlignment = newTextAlignment;
	NSMutableParagraphStyle *newParagraphStyle;
	NSMutableDictionary *attributes;
	
	attributes = [[_text attributesAtIndex:0 effectiveRange:NULL] mutableCopy]; 
	
	newParagraphStyle = [[attributes objectForKey:NSParagraphStyleAttributeName] mutableCopy]; 
	[newParagraphStyle setAlignment:newTextAlignment];
	[attributes setObject:newParagraphStyle forKey:NSParagraphStyleAttributeName];
	
	[_text setAttributes:attributes range:NSMakeRange( 0, [_text length])];
	
	[attributes release];
	
	[_shape strokeUpdated];
}

*/
- (NSBezierPath *)closedBezierPathForTextContainer:(id)aContainer;
{
	return [_shape path];
}

@end
