//
//  DBDrawingView+Exporting.m
//  DrawBerry
//
//  Created by Raphael Bost on 17/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBDrawingView+Exporting.h"


@implementation DBDrawingView (Exporting)

- (CFDictionaryRef)optionsDict
{
	CFMutableDictionaryRef saveOpts;
	saveOpts = CFDictionaryCreateMutable(nil, 0, &kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
	CFDictionaryRef tiffProfs = CFDictionaryGetValue(saveOpts, kCGImagePropertyTIFFDictionary);
    CFMutableDictionaryRef tiffProfsMut;
    if (tiffProfs)
        tiffProfsMut = CFDictionaryCreateMutableCopy(nil, 0, tiffProfs);
    else
        tiffProfsMut = CFDictionaryCreateMutable(nil, 0,
                     &kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(saveOpts, kCGImagePropertyTIFFDictionary, tiffProfsMut);
    CFRelease(tiffProfsMut);
    CFDictionarySetValue(saveOpts, kCGImageDestinationLossyCompressionQuality, 
                                [NSNumber numberWithFloat:1.0]);
	
   return saveOpts;
}

- (NSData *)dataWithFormat:(NSString *)format jpegCompression:(float)compressionFactor
{  
	float zoom = [self zoom];
	[self setExporting:YES];
	[self setZoom:1.0];
	NSData *data; 

	if([format isEqualToString:@"pdf"]) data = [self dataWithPDFInsideRect:_canevasRect];
	else if([format isEqualToString:@"eps"]) data = [self dataWithEPSInsideRect:_canevasRect];
	else if([format isEqualToString:@"jpeg"]) data = [self dataWithJPEGInsideRect:_canevasRect compressionFactor:compressionFactor];
	else if([format isEqualToString:@"png"]) data = [self dataWithPNGInsideRect:_canevasRect];
	else if([format isEqualToString:@"tiff"]) data = [self dataWithTIFFInsideRect:_canevasRect];
	else if([format isEqualToString:@"psd"]) data = [self dataWithPSDInsideRect:_canevasRect];
	else if([format isEqualToString:@"ai"]) data = [self dataWithAIInsideRect:_canevasRect];
	
	[self setZoom:zoom];
	
   	[self setExporting:NO];
	
	return data;
}

- (NSData *)dataWithTIFFInsideRect:(NSRect)rect
{
	NSImage *image;
	NSData *data;
	NSAffineTransform *af = [NSAffineTransform transform];
	
	[af translateXBy:-_canevasRect.origin.x yBy:-_canevasRect.origin.y];

	image = [[NSImage alloc] initWithSize:rect.size];
	[image setFlipped:YES];
	[image lockFocus];	
	
	[af concat];
	[self drawRect:rect];
  	[image unlockFocus];
  
  	data = [image TIFFRepresentation];
	[image release];                  
	
	return data;
}

- (NSData *)dataWithPNGInsideRect:(NSRect)rect
{
	NSImage *image;
	NSData *data;
	NSAffineTransform *af = [NSAffineTransform transform];
	[af translateXBy:-_canevasRect.origin.x yBy:-_canevasRect.origin.y];
	image = [[NSImage alloc] initWithSize:rect.size];
	
	[image setFlipped:YES];
	[image lockFocus];
	[af concat];	
	[self drawRect:rect];
	
	[image unlockFocus];
    
	data = [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:15.0];
 	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:data];
	data = [imageRep representationUsingType:NSPNGFileType properties:nil];
	[image release];                  
	[imageRep release];
	
	return data;	
}

- (NSData *)dataWithJPEGInsideRect:(NSRect)rect compressionFactor:(float)quality
{	
	NSImage *image;
	NSData *data;
	NSAffineTransform *af = [NSAffineTransform transform];
	[af translateXBy:-_canevasRect.origin.x yBy:-_canevasRect.origin.y];
	image = [[NSImage alloc] initWithSize:rect.size];
	
	[image setFlipped:YES];
	[image lockFocus];
	[af concat];	
	[self drawRect:rect];
	
	[image unlockFocus];
    
	data = [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:15.0];
 	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:data];
	data = [imageRep representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:quality] forKey:NSImageCompressionFactor]];
	[image release];                  
	[imageRep release];
	
	return data;	
	
}

- (NSData *)dataWithPSDInsideRect:(NSRect)rect
{
	NSBitmapImageRep *imageRep;
	NSMutableData *data = [NSMutableData data];
	NSAffineTransform *af = [NSAffineTransform transform];
	CGImageRef image;
    CGImageDestinationRef myDestination;
	
	[af translateXBy:-_canevasRect.origin.x yBy:-_canevasRect.origin.y];
	[af scaleXBy:1.0 yBy:-1.0];
	[af translateXBy:0 yBy:-[self canevasSize].height]; 

	
    
	imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:[self canevasSize].width pixelsHigh:[self canevasSize].height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace  bytesPerRow:[self canevasSize].height*4 bitsPerPixel:32];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep]];
   	
	[af concat];
	
	[self drawRect:rect];
    
	[NSGraphicsContext restoreGraphicsState];
	image = CGBitmapContextCreateImage([[NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep] graphicsPort]);
	
    
    
	myDestination = CGImageDestinationCreateWithData((CFMutableDataRef)data,
						CFSTR("com.adobe.photoshop-image"), 1, NULL);
	
	CFDictionaryRef dict = [self optionsDict]; 
	CGImageDestinationAddImage(myDestination, (CGImageRef)image, dict);
 	if (!CGImageDestinationFinalize(myDestination))
	{
		NSLog(@"error");
	}else {
		CFRelease(myDestination);
	}

	
	CFRelease(image);
	
	CFRelease(dict);
	[imageRep release];
	
	return data;                  
}

- (NSData *)dataWithAIInsideRect:(NSRect)rect
{
	NSBitmapImageRep *imageRep;
	NSMutableData *data = [NSMutableData data];
	NSAffineTransform *af = [NSAffineTransform transform];
	CGImageRef image;
    CGImageDestinationRef myDestination;
	
	[af translateXBy:-_canevasRect.origin.x yBy:-_canevasRect.origin.y];
	[af scaleXBy:1.0 yBy:-1.0];
	[af translateXBy:0 yBy:-[self canevasSize].height]; 

	
    
	imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:[self canevasSize].width pixelsHigh:[self canevasSize].height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace  bytesPerRow:[self canevasSize].height*4 bitsPerPixel:32];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep]];
   	
	[af concat];
	
	[self drawRect:rect];
    
	[NSGraphicsContext restoreGraphicsState];
	image = CGBitmapContextCreateImage([[NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep] graphicsPort]);
	
    
    
	myDestination = CGImageDestinationCreateWithData((CFMutableDataRef)data,
						CFSTR("com.adobe.illustrator.ai-image"), 1, NULL);
					
	CFDictionaryRef dict = [self optionsDict];
	CGImageDestinationAddImage(myDestination, (CGImageRef)image, dict);
 	if (!CGImageDestinationFinalize(myDestination))
	{
		NSLog(@"error");
	}else {
		CFRelease(myDestination);
	}

	
	CFRelease(image);
	CFRelease(dict);
	[imageRep release];
	
	return data;                  
}
@end
