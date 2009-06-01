//
//  DBSVGParser.m
//  DBSVGReader
//
//  Created by Raphael Bost on 12/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBSVGParser.h"

#import "DBLayer.h"
#import "DBRectangle+SVG.h"
#import "DBPolyline+SVG.h"
#import "DBBezierCurve+SVG.h"

@implementation DBSVGParser
+ (id)SVGParser
{
	return [[[self alloc] init] autorelease];
}     

+ (NSArray *)parseSVGFile:(NSString *)pathToFile
{
	return [[[[self alloc] init] autorelease] parseSVGFile:pathToFile];
}                                      

+ (NSArray *)parseSVGURL:(NSURL *)urlToFile
{
	return [[[[self alloc] init] autorelease] parseSVGURL:urlToFile];
}
- (id)init
{
	self = [super init];
	
   	_parsedLayers = [[NSMutableArray alloc] init];            
	
	return self;
}     

- (void)dealloc
{	
	[_parsedLayers release];
	
	[super dealloc];
}           

- (NSArray *)parseSVGFile:(NSString *)pathToFile {
    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];

	return [self parseSVGURL:xmlURL];
}                        

- (NSArray *)parseSVGURL:(NSURL *)urlToFile;
{
    BOOL success;
//    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];
    if (_parser) // addressParser is an NSXMLParser ivar
        [_parser release];
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:urlToFile];
    [_parser setDelegate:self];
    [_parser setShouldResolveExternalEntities:YES];
    success = [_parser parse]; // return value not used
                // if not successful, delegate is informed of error 

	NSLog(@"parse finished");
	return _parsedLayers;
	
}

- (NSArray *)parsedLayers
{
	return _parsedLayers;
}


#pragma mark Parser Events

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    //NSLog(@"start : name : %@ , attributes : %@",elementName,attributeDict);
	              
	NSString *styleString = [[attributeDict objectForKey:@"style"] copy];
	NSString *key, *object;
	NSMutableDictionary *newAttr = [[NSMutableDictionary alloc] initWithDictionary:attributeDict];

	NSArray *styleArray, *elementArray;              
	
	if(styleString){      
		[newAttr removeObjectForKey:@"syle"];
		
		styleArray = [styleString componentsSeparatedByString:@";"];
		
		NSEnumerator *e = [styleArray objectEnumerator];
		NSString * element;

		while((element = [e nextObject])){
			elementArray = [element componentsSeparatedByString:@":"];
			key = [elementArray objectAtIndex:0];                  
		   	object = [elementArray objectAtIndex:1];
			[newAttr setObject:object forKey:key];
		}
	}
	
	[styleString release];
	
//	NSLog(@"start : name : %@ , attributes : %@",elementName,newAttr);
  
  	if([elementName isEqualTo:@"g"] && [[newAttr objectForKey:@"inkscape:groupmode"] isEqualTo:@"layer"]){
		// add a layer
		_currentLayer = [[DBLayer alloc] initWithName:@""];
	}else if([elementName isEqualTo:@"rect"]){
		// add a rectangle to current layer
		if(!_currentLayer){
			_currentLayer = [[DBLayer alloc] initWithName:@""];			
		}
		
		DBRectangle *rect;
		rect = [[DBRectangle alloc] initWithSVGAttributes:newAttr];
		
		[_currentLayer addShape:rect];
		[rect release];
	}else if([elementName isEqualTo:@"ellipse"]){
		// add an ellipse to current layer
//		if(!_currentLayer){
//			_currentLayer = [[DBLayer alloc] initWithName:@""];			
//		}

//		DBRectangle *rect;
//		rect = [[DBRectangle alloc] initWithSVGAttributes:newAttr];
    }else if([elementName isEqualTo:@"path"]){
		if(!_currentLayer){
			_currentLayer = [[DBLayer alloc] initWithName:@""];			
		}

		// determine whether it is a polyline or a bezier curve
		NSString *pathString;
		
		pathString = [newAttr objectForKey:@"d"];
		if([pathString rangeOfString:@"c" options:NSCaseInsensitiveSearch].location == NSNotFound){ //polyline
			DBPolyline *polyline;
			polyline = [[DBPolyline alloc] initWithSVGAttributes:newAttr];
			
			[_currentLayer addShape:polyline];
			[polyline release];
		}else{ // bezier curve
			DBBezierCurve *bezierCurve;
			bezierCurve = [[DBBezierCurve alloc] initWithSVGAttributes:newAttr];
		
			[_currentLayer addShape:bezierCurve];
			[bezierCurve release];
		}
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//NSLog(@"end : name : %@",elementName);
	
	//here, add the elements
	if([elementName isEqualTo:@"g"]){
		[_parsedLayers addObject:_currentLayer];
		[_currentLayer release];
		_currentLayer = nil;
	}else{
		// do nothing
	}                       
	
}
@end