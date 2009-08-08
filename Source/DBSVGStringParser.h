//
//  DBSVGStringParser.h
//  DrawBerry
//
//  Created by Raphael Bost on 01/06/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBSVGStringParser : NSObject {
	id owner;
}
- (id)initWithOwner:(id)o;
- (void)parseString:(NSString *)s;
- (void)lineTo:(NSPoint)p;
- (void)moveTo:(NSPoint)p;
- (void)curveToPoint:(NSPoint)aPoint controlPoint1:(NSPoint)controlPoint1 controlPoint2:(NSPoint)controlPoint2;
- (void)closePath;
@end

@interface NSObject (SVGStringParserOwner)
- (void)SVGMoveTo:(NSPoint)p;
- (void)SVGLineTo:(NSPoint)p;
- (void)SVGCurveToPoint:(NSPoint)aPoint controlPoint1:(NSPoint)controlPoint1 controlPoint2:(NSPoint)controlPoint2;
- (void)SVGClosePath;
@end

