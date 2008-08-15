//
//  DBLayer+SVG.m
//  DrawBerry
//
//  Created by Raphael Bost on 06/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBLayer+SVG.h"
#import "DBShape+SVG.h"


@implementation DBLayer (SVGAdditions)
- (NSString *)SVGString
{
	NSMutableString *buffer;
	buffer = [[NSMutableString alloc] init];
	
	[buffer appendString:[NSString stringWithFormat:@"<g inkscape:label=\"%@\" inkscape:groupmode=\"layer\" id=\"%@\">\n",[self name],[self name]]];
	
	NSEnumerator *e = [_shapes objectEnumerator];
	DBShape * shape;

	while((shape = [e nextObject])){
		[buffer appendString:[shape SVGString]];
	}
	
	[buffer appendString:@"</g>\n"];
	return [buffer autorelease];
}             
@end
