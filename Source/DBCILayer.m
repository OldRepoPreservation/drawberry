//
//  DBCILayer.m
//  DrawBerry
//
//  Created by Raphael Bost on 30/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBCILayer.h"
#import "DBDrawingView.h"
#import "DBShape.h"

#import <QuartzCore/QuartzCore.h>

#import "DBFilterStack.h"

#import "DBCIFilterPoint.h"


@implementation DBCILayer

- (id)initWithName:(NSString *)name
{
	self = [super initWithName:name];
	
	_filterStack = [[DBFilterStack alloc] init];            
	[_filterStack setLayer:self];
	
	return self;
}

- (void)dealloc
{
	[_filterStack release];
	
	[super dealloc];
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	
	_filterStack = [[decoder decodeObjectForKey:@"Filter Stack"] retain];
	[_filterStack setLayer:self];
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:_filterStack forKey:@"Filter Stack"];
}

- (BOOL)editable
{
	return NO;
}

- (BOOL)drawUnderneathLayers
{
	return NO;
} 

- (NSArray *)underneathLayers
{
	DBLayer *layer = [[self layerController] previousLayer:self];
	
	if(layer) 
		return [NSArray arrayWithObject:layer];
	
	return nil;
}   

- (void)updateRenderInView:(NSView *)view
{
	[self willChangeValueForKey:@"render"]; 	
	[_ciRender release];
	DBLayer *layer = [[self layerController] previousLayer:self];
	CGLayerRef renderLayer = [layer renderLayer];
	CIImage *image = nil;
	
	//	NSLog(@"update ci layer : %d", renderLayer);
	
	if([_layerController editingLayer] != layer){
		image = [[CIImage alloc] initWithCGLayer:renderLayer];		
	}else{
	}
    
	if(!renderLayer){
		//		NSLog(@"previous render nil");
	}
	
	_ciRender = [[_filterStack applyFiltersToImage:image] retain];
	
	[image release];
	
	[self didChangeValueForKey:@"render"]; 	
}

- (void)displayRenderInRect:(NSRect)rect
{
	[self drawInView:[[self layerController]drawingView] rect:rect];
}

- (void)drawInView:(NSView *)view rect:(NSRect)rect
{
//	NSLog(@"rendering rect and zoom : %@, %f",NSStringFromRect(rect), [(DBDrawingView *)view zoom]);
	CIContext *context;
	NSGraphicsContext *mainContext = [NSGraphicsContext currentContext] ;
	
	//	CGContextSaveGState([mainContext graphicsPort]);
	
	//	CGContextSetBlendMode([mainContext graphicsPort], [[[self layerController] previousLayer:self] blendMode]);
	//	CGContextSetAlpha([mainContext graphicsPort], [[[self layerController] previousLayer:self] alpha]);
	
	context = [mainContext CIContext];
	//	NSLog(@"CIContext : %@",context);

	CGRect cgr;
//	cgr = CGRectMake(0, 0, rect.size.width*[(DBDrawingView *)view zoom], rect.size.height*[(DBDrawingView *)view zoom]);
	cgr = CGRectMake(0, 0, rect.size.width, rect.size.height);
	
	if(context){
		//	  	NSLog(@"CIImage render : %@", _ciRender);
		if ([context respondsToSelector:@selector(createCGImage:fromRect:format:colorSpace:)] ){
//			CIImage *image;
//			image = [CIImage imageWithColor:[CIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0]];

			CGImageRef cgImage;
			
			cgImage = [context createCGImage:_ciRender fromRect:cgr];			
			
			if (cgImage != NULL)
			{
				CGContextDrawImage ([[NSGraphicsContext currentContext]
									 graphicsPort], cgr, cgImage);
				CGImageRelease (cgImage);
				
				
			}
			
		}else{
						
			
			
			//[context drawImage:image atPoint:CGPointZero fromRect:CGRectMake(0, 0, rect.size.width*[(DBDrawingView *)view zoom], rect.size.height*[(DBDrawingView *)view zoom])]; 
			[context drawImage:_ciRender atPoint:CGPointZero fromRect:cgr]; 
		}	
		
		if([_layerController selectedLayer] == self){
			if(![[[self layerController] drawingView] isExporting]){
				[self drawFilterPoints];                     
			}
		}else if([_layerController editingLayer] == [[self layerController] previousLayer:self]){
			//		NSLog(@"display previous layer");
			[[_layerController editingLayer] drawInView:view rect:rect];
		}
		
	}else{
		[[[self layerController] previousLayer:self] drawInView:view rect:rect];
	}
	
	//	CGContextRestoreGState([mainContext graphicsPort]);
	//	[[[self layerController] previousLayer:self] drawInView:view rect:rect];
	
}

- (void)drawFilterPoints
{
	CIFilterPoint *points = [_filterStack filterPoints];
	int count = [_filterStack filterPointsCount];
	NSPoint p;
  	int i;
	
	for( i = 0; i < count; i++ )
   	{
		p = DBPointForCIFilterPoint(points[i]);
		[DBShape drawGreenKnobAtPoint:p];
	}
}

- (BOOL)moveFilterPoints:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	CIFilterPoint ciPoint;
	NSPoint mouseLocation;
	BOOL canConvert; 
	NSAutoreleasePool *pool;
	
	canConvert = [view isKindOfClass:[DBDrawingView class]];
	mouseLocation = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	mouseLocation = [view canevasCoordinatesFromViewCoordinates:mouseLocation];
	
	ciPoint = [_filterStack filterPointUnderPoint:mouseLocation];
	
	if(ciPoint.filter == nil){
		return NO;
	}
	
	while(YES){
		pool = [[NSAutoreleasePool alloc] init];
		
		theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
		mouseLocation = [view convertPoint:[theEvent locationInWindow] fromView:nil];
		
		if(canConvert){
			mouseLocation = [view pointSnapedToGrid:mouseLocation];
			mouseLocation = [view canevasCoordinatesFromViewCoordinates:mouseLocation];
		}
		
		DBSetCIFilterPoint(ciPoint, mouseLocation);
		
		[self updateRenderInView:nil];
		[view setNeedsDisplay:YES];
		
		[pool release];
		if([theEvent type] == NSLeftMouseUp)
		{     
			break;
		}
	}
	
	//    [self updateRenderInView:nil];
	
	return YES;
}   

- (DBFilterStack *)filterStack
{
	return _filterStack;
}

@end
