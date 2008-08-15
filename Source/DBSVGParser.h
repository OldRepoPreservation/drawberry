//
//  DBSVGParser.h
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBLayer;

@interface DBSVGParser : NSObject {
	NSXMLParser *_parser;
	NSMutableArray *_parsedLayers;
	
	DBLayer *_currentLayer;
}
+ (id)SVGParser;
+ (NSArray *)parseSVGFile:(NSString *)pathToFile;
+ (NSArray *)parseSVGURL:(NSURL *)urlToFile;
- (NSArray *)parseSVGFile:(NSString *)pathToFile;
- (NSArray *)parseSVGURL:(NSURL *)urlToFile;
@end
