//
//  DBSVGParser.h
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBLayer;

@interface DBSVGParser : NSObject <NSXMLParserDelegate> {
	NSXMLParser *_parser;
	NSMutableArray *_parsedLayers;
	
	DBLayer *_currentLayer;
	
	BOOL _ignoreElements;
}
+ (id)SVGParser;
+ (NSArray *)parseSVGFile:(NSString *)pathToFile;
+ (NSArray *)parseSVGURL:(NSURL *)urlToFile;
- (NSArray *)parseSVGFile:(NSString *)pathToFile;
- (NSArray *)parseSVGURL:(NSURL *)urlToFile;
- (void)parseSVGURLInNewThread:(NSURL *)urlToFile;

- (NSArray *)parsedLayers;
@end