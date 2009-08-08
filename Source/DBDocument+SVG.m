//
//  DBDocument+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 06/07/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import "DBDocument+SVG.h"
#import "DBLayer+SVG.h"
#import "DBDrawingView.h"


@implementation DBDocument (SVGAdditions)
- (NSString *)SVGString
{
	NSMutableString *buffer;
	NSArray *layers;
	NSSize canevasSize;
	
	buffer = [[NSMutableString alloc] init];
	
	[buffer appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"];
                            
	[buffer appendString:@"<!-- Created with DrawBerry (http://raphaelbost.free.fr/) -->\n"];
	
	canevasSize = [[self drawingView] canevasSize];

	[buffer appendString:[NSString stringWithFormat:@"<svg \n \t width = \"%f\" \n \t height = \"%f\" \n",canevasSize.width,canevasSize.height]];                            
	[buffer appendString:@"xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n"];
	[buffer appendString:@"xmlns:cc=\"http://web.resource.org/cc/\"\n"];
   	[buffer appendString:@"xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n "];
   	[buffer appendString:@"xmlns:svg=\"http://www.w3.org/2000/svg\"\n "];
   	[buffer appendString:@"xmlns=\"http://www.w3.org/2000/svg\" \n "];
   	[buffer appendString:@"xmlns:sodipodi=\"http://inkscape.sourceforge.net/DTD/sodipodi-0.dtd\"\n "];
   	[buffer appendString:@"xmlns:inkscape=\"http://www.inkscape.org/namespaces/inkscape\"\n >\n"];
	
	layers = [[self layerController] layers];

	NSEnumerator *e = [layers objectEnumerator];
	DBLayer * layer;
	
	while((layer = [e nextObject])){
		[buffer appendString:[layer SVGString]];
	}
	
	[buffer appendString:@"</svg>\n"];
	
	return [buffer autorelease];
}
@end
