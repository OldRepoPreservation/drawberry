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

	//_gradient = [[GCGradient gradientWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]] retain];
	_gradient = [[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]];
	[self resetImageDrawPoint];
	[self resetGradientPoints];
	
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
	_fillImage = [[decoder decodeObjectForKey:@"Fill Image"] retain]; 
	_gradient = [[decoder decodeObjectForKey:@"Gradient"] retain]; 
	
	_imageDrawPoint = [decoder decodePointForKey:@"Draw Point"];
	
	_grdType = [decoder decodeIntForKey:@"Gradient Type"];
	_grdStartingPoint = [decoder decodePointForKey:@"Starting Point"];
	_grdEndingPoint = [decoder decodePointForKey:@"Ending Point"];
	_grdStartingRadius = [decoder decodeFloatForKey:@"Starting Radius"];
	_grdEndingRadius = [decoder decodeFloatForKey:@"Ending Radius"];
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:_fillMode forKey:@"Fill Mode"];
	[encoder encodeInt:_imageFillMode forKey:@"Image Fill Mode"]; 
	[encoder encodeObject:_fillColor forKey:@"Fill Color"];
	[encoder encodeObject:_fillImage forKey:@"Fill Image"];
	[encoder encodeObject:_gradient forKey:@"Gradient"];
	[encoder encodePoint:_imageDrawPoint forKey:@"Draw Point"];
	
	[encoder encodeInt:_grdType forKey:@"Gradient Type"];
	[encoder encodePoint:_grdStartingPoint forKey:@"Starting Point"];
	[encoder encodePoint:_grdEndingPoint forKey:@"Ending Point"];
	[encoder encodeFloat:_grdStartingRadius forKey:@"Starting Radius"];
	[encoder encodeFloat:_grdEndingRadius forKey:@"Ending Radius"];
	//[encoder encodeObject:_text forKey:@"Text"];
}

#pragma mark Updating and filling
- (void)fillPath:(NSBezierPath *)path
{
	if(_fillMode == DBColorFillMode){
		[_fillColor set];
		[path fill];
	}else if(_fillMode == DBImageFillMode){
		[_fillCache drawAtPoint:[_shape bounds].origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}else if(_fillMode == DBGradientFillMode){

		if(_grdType == GPLinearType){
			[_gradient drawInBezierPath:path angle:_grdAngle];
		}else{
			//[_gradient drawInBezierPath:path relativeCenterPosition:NSZeroPoint];
			NSAffineTransform *translation= [NSAffineTransform transform];
			NSAffineTransform *scale = [NSAffineTransform transform];
			[scale scaleBy:[_shape zoom]];
			[translation translateXBy:[_shape bounds].origin.x yBy:[_shape bounds].origin.y];

			[NSGraphicsContext saveGraphicsState];
			[path addClip];
			[translation concat];
			[scale concat];
			
//			[_gradient drawFromCenter:_grdStartingPoint radius:_grdBeginRadius toCenter:_grdEndingPoint radius:40.0 options:0];
			[_gradient drawFromCenter:_grdStartingPoint radius:_grdStartingRadius toCenter:_grdEndingPoint radius:_grdEndingRadius options:(NSGradientDrawsBeforeStartingLocation | NSGradientDrawsAfterEndingLocation)];
			[NSGraphicsContext restoreGraphicsState];
		}
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
	else if(_fillMode == DBGradientFillMode)
		[self resetGradientPoints];
	
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

- (NSGradient *)gradient
{
	return _gradient;
}

- (void)setGradient:(NSGradient *)newGradient
{
	[newGradient retain];
	[_gradient release];
	_gradient = newGradient;

   	[_shape strokeUpdated];
}

- (CGFloat)gradientAngle
{
	return -_grdAngle;
}

- (void)setGradientAngle:(CGFloat)angle
{
	_grdAngle = angle;
	[_shape strokeUpdated];
}

- (GPGradientType)gradientType
{
	return _grdType;
}

- (void)setGradientType:(GPGradientType)type
{
	_grdType = type;
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

- (NSPoint)gradientStartingPoint
{
	return _grdStartingPoint;
}
- (void)setGradientStartingPoint:(NSPoint)newPoint
{
	_grdStartingPoint = newPoint;
	
   	[_shape strokeUpdated];
}

- (NSPoint)gradientEndingPoint
{
	return _grdEndingPoint;
}
- (void)setGradientEndingPoint:(NSPoint)newPoint
{
	_grdEndingPoint = newPoint;
	
   	[_shape strokeUpdated];
}

- (CGFloat)gradientStartingRadius
{
	return _grdStartingRadius;
}
- (void)setGradientStartingRadius:(CGFloat)radius
{
	_grdStartingRadius = radius;
	[_shape strokeUpdated];
}
- (CGFloat)gradientEndingRadius
{
	return _grdEndingRadius;
}
- (void)setGradientEndingRadius:(CGFloat)radius
{
	_grdEndingRadius = radius;
	[_shape strokeUpdated];
}

- (void)resetGradientPoints
{
	_grdStartingPoint.x = 1*([_shape bounds].size.width/[_shape zoom])/2;
	_grdStartingPoint.y = 1*([_shape bounds].size.height/[_shape zoom])/2;
	
	_grdEndingPoint.x = 1*([_shape bounds].size.width/[_shape zoom])/2;
	_grdEndingPoint.y = 1*([_shape bounds].size.height/[_shape zoom])/2;
	
	_grdStartingRadius = 0.0;
	_grdEndingRadius = MIN([_shape bounds].size.width, [_shape bounds].size.height)/2;
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

- (NSBezierPath *)closedBezierPathForTextContainer:(id)aContainer;
{
	return [_shape path];
}

@end
