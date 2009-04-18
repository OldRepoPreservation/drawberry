//
//  DBStroke.m
//  DrawBerry
//
//  Created by Raphael Bost on 19/05/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBStroke.h"

#import "DBShape.h"

#import "NSBezierPath+Extensions.h"

#import "NSBezierPath+Geometry.h"
#import "DKGeometryUtilities.h"
#import "DKDrawKitMacros.h"

   
@class DBPolyline;

@implementation DBStroke
+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObject:@"strokeMode"] triggerChangeNotificationsForDependentKey:@"needsColor"];
	[self setKeys:[NSArray arrayWithObject:@"strokeMode"] triggerChangeNotificationsForDependentKey:@"needsPatternImage"];
}

- (id)initWithShape:(DBShape *)shape
{
	self = [super init];
	               
	// do not retain shape or there will be a retain loop
	
	_shape = shape;
	
	_stroke = YES;
	
	_strokeMode = 0;
	_lineWidth = 1.0;
	_lineJoinStyle = NSMiterLineJoinStyle;
	_lineCapStyle = NSButtLineCapStyle;
	
	_arrowStyle = 0;
	_dashStyle = 0;
	
	_strokeColor = [[NSColor blackColor] retain];            
	_patternImage = nil;
	
	m_scale = 1.0;
	m_interval = 40.0;
	NSAssert(m_leader == 0.0, @"Expected init to zero");
	NSAssert(m_leadInLength == 0.0, @"Expected init to zero");
	NSAssert(m_leadOutLength == 0.0, @"Expected init to zero");
	m_liloProportion = 0.2;
	m_normalToPath = YES;
	_useRamp = YES;
	_rampPeriod = 0.5;
	_rampPhase = 0.0;
	
	_showStartArrow = NO;
	_showEndArrow = NO;
	_startArrowStyle = 0;
	_endArrowStyle = 0;
	[self setStartArrowFillColor:[NSColor whiteColor]];
	[self setEndArrowFillColor:[NSColor whiteColor]];
    _strokeStartArrow = YES;
	_strokeEndArrow = YES;
    _fillStartArrow = YES;
    _fillEndArrow = YES;

	_textOffset = 2.0;
	
	return self;
}

- (void)dealloc
{
	[_strokeColor release];
	[_patternImage release];
	[_text release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	DBStroke *stroke = [[DBStroke alloc] init];
	
	[stroke setStrokeMode:[self strokeMode]];
	[stroke setLineWidth:[self lineWidth]];
	[stroke setLineJoinStyle:[self lineJoinStyle]];
	[stroke setLineCapStyle:[self lineCapStyle]];
	[stroke setArrowStyle:[self arrowStyle]];
	[stroke setDashStyle:[self dashStyle]];
	[stroke setStrokeColor:[[[self strokeColor] copy] autorelease]];
	[stroke setPatternImage:[[[self patternImage] copy] autorelease]];
    
	[stroke setShowStartArrow:[self showStartArrow]];
	[stroke setShowEndArrow:[self showEndArrow]];
	[stroke setStartArrowStyle:[self startArrowStyle]];
	[stroke setEndArrowStyle:[self endArrowStyle]];
   	[stroke setStartArrowFillColor:[[[self startArrowFillColor] copy] autorelease]];
   	[stroke setEndArrowFillColor:[[[self endArrowFillColor] copy] autorelease]];
	[stroke setStrokeStartArrow:[self strokeStartArrow]];
	[stroke setStrokeEndArrow:[self strokeEndArrow]];
	[stroke setFillStartArrow:[self fillStartArrow]];
	[stroke setFillEndArrow:[self fillEndArrow]];
    
   	[stroke setText:[[[self text] copy] autorelease]];
	[stroke setTextOffset:[self textOffset]];

	return stroke;
} 

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	_strokeMode = [decoder decodeIntForKey:@"Stroke Mode"];            
	_lineWidth = [decoder decodeFloatForKey:@"Line Width"];
 	_lineJoinStyle = [decoder decodeIntForKey:@"Line Join Style"];            
	_lineCapStyle = [decoder decodeIntForKey:@"Line Cap Style"];            
	_dashStyle = [decoder decodeIntForKey:@"Dash Style"];            
	_strokeColor = [[decoder decodeObjectForKey:@"Stroke Color"] retain];
	_patternImage = [[decoder decodeObjectForKey:@"Pattern Image"] retain];
	
	_showStartArrow = [decoder decodeBoolForKey:@"Show Start Arrow"];
	_showEndArrow = [decoder decodeBoolForKey:@"Show End Arrow"];
	_strokeStartArrow = [decoder decodeBoolForKey:@"Stroke Start Arrow"];
	_strokeEndArrow = [decoder decodeBoolForKey:@"Stroke End Arrow"];
	_fillStartArrow = [decoder decodeBoolForKey:@"Fill Start Arrow"];
	_fillEndArrow = [decoder decodeBoolForKey:@"Fill End Arrow"];
	_startArrowStyle = [decoder decodeIntForKey:@"Start Arrow Style"];            
	_endArrowStyle = [decoder decodeIntForKey:@"End Arrow Style"];            
	_startArrowFillColor = [[decoder decodeObjectForKey:@"Start Arrow Fill Color"] retain];
	_endArrowFillColor = [[decoder decodeObjectForKey:@"End Arrow Fill Color"] retain];
	
	_text = [[decoder decodeObjectForKey:@"Stroke Text"] retain];
	_textOffset = [decoder decodeFloatForKey:@"Text Offset"];
	
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeInt:_strokeMode forKey:@"Stroke Mode"];
	[encoder encodeFloat:_lineWidth forKey:@"Line Width"];
	[encoder encodeInt:_lineJoinStyle forKey:@"Line Join Style"]; 
	[encoder encodeInt:_lineCapStyle forKey:@"Line Cap Style"]; 
	[encoder encodeInt:_dashStyle forKey:@"Dash Style"]; 
	[encoder encodeObject:_strokeColor forKey:@"Stroke Color"];
	[encoder encodeObject:_patternImage forKey:@"Pattern Image"];
    
	[encoder encodeBool:_showStartArrow forKey:@"Show Start Arrow"];
	[encoder encodeBool:_showEndArrow forKey:@"Show End Arrow"];
	[encoder encodeBool:_strokeStartArrow forKey:@"Stroke Start Arrow"];
	[encoder encodeBool:_strokeEndArrow forKey:@"Stroke End Arrow"];
	[encoder encodeBool:_fillStartArrow forKey:@"Fill Start Arrow"];
	[encoder encodeBool:_fillEndArrow forKey:@"Fill End Arrow"];
    [encoder encodeInt:_startArrowStyle forKey:@"Start Arrow Style"]; 
	[encoder encodeInt:_endArrowStyle forKey:@"End Arrow Style"]; 
	[encoder encodeObject:_startArrowFillColor forKey:@"Start Arrow Fill Color"];
	[encoder encodeObject:_endArrowFillColor forKey:@"End Arrow Fill Color"];


	[encoder encodeObject:_text forKey:@"Stroke Text"];
	[encoder encodeFloat:_textOffset forKey:@"Text Offset"];
}

#pragma mark Accessors
- (BOOL)stroke
{
	return _stroke;
}

- (void)setStroke:(BOOL)newStroke
{
	_stroke = newStroke;
}

- (int)strokeMode
{
	return _strokeMode;
}

- (void)setStrokeMode:(int)newStrokeMode
{
	_strokeMode = newStrokeMode;
	[_shape strokeUpdated];
}

- (BOOL)needsColor
{
	return (_strokeMode == DBColorStrokeMode);
}   

- (BOOL)needsPatternImage
{
	return (_strokeMode == DBImagePatternStrokeMode);
}   

- (float)lineWidth
{
	return _lineWidth;
}

- (void)setLineWidth:(float)newLineWidth
{
	_lineWidth = newLineWidth;
	[_shape strokeUpdated];
}

- (int)lineJoinStyle
{
	return _lineJoinStyle;
}

- (void)setLineJoinStyle:(int)newLineJoinStyle
{
	_lineJoinStyle = newLineJoinStyle;
	[_shape strokeUpdated];
}

- (int)lineCapStyle
{
	return _lineCapStyle;
}

- (void)setLineCapStyle:(int)newLineCapStyle
{
	_lineCapStyle = newLineCapStyle;
	[_shape strokeUpdated];
}

- (int)arrowStyle
{
	return _arrowStyle;
}

- (void)setArrowStyle:(int)newArrowStyle
{
	_arrowStyle = newArrowStyle;
	[_shape strokeUpdated];
}

- (int)dashStyle
{
	return _dashStyle;
}

- (void)setDashStyle:(int)newDashStyle
{
	_dashStyle = newDashStyle;
	[_shape strokeUpdated];
}

- (NSColor *)strokeColor
{
	return _strokeColor;
}

- (void)setStrokeColor:(NSColor *)newStrokeColor
{
	[newStrokeColor retain];
	[_strokeColor release];
	_strokeColor = newStrokeColor;
	[_shape strokeUpdated];
}

- (NSImage *)patternImage
{
	return _patternImage;
}

- (void)setPatternImage:(NSImage *)newPatternImage
{
	[newPatternImage retain];
	[_patternImage release];
	_patternImage = newPatternImage;
	[_shape strokeUpdated];
}

#pragma mark Arrows Accessors

- (BOOL)showStartArrow
{
	return _showStartArrow;
}

- (void)setShowStartArrow:(BOOL)newShowStartArrow
{
	_showStartArrow = newShowStartArrow;
	[_shape strokeUpdated];
}

- (BOOL)showEndArrow
{
	return _showEndArrow;
}

- (void)setShowEndArrow:(BOOL)newShowEndArrow
{
	_showEndArrow = newShowEndArrow;
	[_shape strokeUpdated];
}

- (DBArrowStyle)startArrowStyle
{
	return _startArrowStyle;
}

- (void)setStartArrowStyle:(DBArrowStyle)newStartArrowStyle
{
	_startArrowStyle = newStartArrowStyle;
	[_shape strokeUpdated];
}

- (DBArrowStyle)endArrowStyle
{
	return _endArrowStyle;
}

- (void)setEndArrowStyle:(DBArrowStyle)newEndArrowStyle
{
	_endArrowStyle = newEndArrowStyle;
	[_shape strokeUpdated];
}

- (NSColor *)startArrowFillColor
{
	return _startArrowFillColor;
}

- (void)setStartArrowFillColor:(NSColor *)newStartArrowFillColor
{
	[newStartArrowFillColor retain];
	[_startArrowFillColor release];
	_startArrowFillColor = newStartArrowFillColor;
	[_shape strokeUpdated];
}

- (NSColor *)endArrowFillColor
{
	return _endArrowFillColor;
}

- (void)setEndArrowFillColor:(NSColor *)newEndArrowFillColor
{
	[newEndArrowFillColor retain];
	[_endArrowFillColor release];
	_endArrowFillColor = newEndArrowFillColor;
	[_shape strokeUpdated];
}

- (BOOL)strokeStartArrow
{
	return _strokeStartArrow;
}

- (void)setStrokeStartArrow:(BOOL)newStrokeStartArrow
{
	_strokeStartArrow = newStrokeStartArrow;
	[_shape strokeUpdated];
}

- (BOOL)strokeEndArrow
{
	return _strokeEndArrow;
}

- (void)setStrokeEndArrow:(BOOL)newStrokeEndArrow
{
	_strokeEndArrow = newStrokeEndArrow;
	[_shape strokeUpdated];
}

- (BOOL)fillStartArrow
{
	return _fillStartArrow;
}

- (void)setFillStartArrow:(BOOL)newFillStartArrow
{
	_fillStartArrow = newFillStartArrow;
	[_shape strokeUpdated];
}

- (BOOL)fillEndArrow
{
	return _fillEndArrow;
}

- (void)setFillEndArrow:(BOOL)newFillEndArrow
{
	_fillEndArrow = newFillEndArrow;
	[_shape strokeUpdated];
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

# pragma mark  Text

- (NSAttributedString *)text
{
	return _text;
}

- (void)setText:(NSAttributedString *)newText
{
	[_text release];
	_text = [newText mutableCopy];
	
	[_textPath release];
	_textPath = nil ;
	[_shape strokeUpdated];
}

- (float)textOffset
{
	return _textOffset;
}

- (void)setTextOffset:(float)newTextOffset
{
	_textOffset = newTextOffset;
	[_shape strokeUpdated];
}

- (BOOL)flipText
{
	return _flipText;
}

- (void)setFlipText:(BOOL)newFlipText
{
	_flipText = newFlipText;
	[_shape strokeUpdated] ;
}

- (BOOL)toggleFlipText
{
	return NO;
}             

- (void)setToggleFlipText:(BOOL)flag
{
	[self setFlipText:!_flipText];
}   
                         
- (int)textPosition
{
	return _textPosition;
}

- (void)setTextPosition:(int)newTextPosition
{
	_textPosition = newTextPosition;
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
	
	if(!newParagraphStyle){
		newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
	} 
	[newParagraphStyle setAlignment:newTextAlignment];
	[attributes setObject:newParagraphStyle forKey:NSParagraphStyleAttributeName];
	
	[_text setAttributes:attributes range:NSMakeRange( 0, [_text length])];
	
	[attributes release];
	[newParagraphStyle release];
	
	[_shape strokeUpdated];
}


# pragma mark  Drawing the path

- (void)updateStrokeForPath:(NSBezierPath *)drawPath
{
	NSBezierPath *path = drawPath;
	
	if([_shape isKindOfClass:[DBPolyline class]]){
		if([path elementAtIndex:[path elementCount] -2] == NSClosePathBezierPathElement){ 

			path = [[NSBezierPath alloc] init];
			NSPoint point;
			
			[drawPath elementAtIndex:0 associatedPoints:&point];
			[path moveToPoint:point];
			
			int i;

			for( i = 1; i < [drawPath elementCount]-2; i++ )
			{
				[drawPath elementAtIndex:i associatedPoints:&point];
				[path lineToPoint:point];
			}

			[drawPath elementAtIndex:0 associatedPoints:&point];
			[path lineToPoint:point];
			[path closePath];			
		}
	}
	
	
	[_textPath release];
	
	if(_text && ![[_text string] isEqualTo:@""]){
		if(_flipText){
 			_textPath = [[path bezierPathByReversingPath] bezierPathWithTextOnPath:_text yOffset:_textOffset];
		}else{
			_textPath = [path bezierPathWithTextOnPath:_text yOffset:_textOffset];
		}
	}
	
	
	[_textPath retain];
	NSAffineTransform *at = [[NSAffineTransform alloc] init]; 
	[at translateXBy:-[_shape bounds].origin.x yBy:-[_shape bounds].origin.y];
	[_textPath transformUsingAffineTransform:at ];
	[at release];
	
	if([_shape isKindOfClass:[DBPolyline class]] && 
		[path elementAtIndex:[path elementCount] -2] == NSClosePathBezierPathElement){
			[path release];
	}
}   

- (void)strokePath:(NSBezierPath *)drawPath
{
	[NSGraphicsContext saveGraphicsState];

	if(_strokeMode != DBNoStrokeMode){
	
		NSBezierPath *path = [drawPath copy];
		NSColor *mainPathColor;
		NSBezierPath *startArrow, *endArrow;
	
		[path setLineWidth:_lineWidth];
		[path setLineJoinStyle:_lineJoinStyle];
		[path setLineCapStyle:_lineCapStyle];
	
		if(_strokeMode == DBColorStrokeMode){
				
				mainPathColor = _strokeColor;                  
		
			[mainPathColor set];
		 
			[path stroke];

			if(_showStartArrow){
				startArrow = [path startArrowWithType:_startArrowStyle options:DBDefaultArrowOptions()];
				if(!(_startArrowStyle == DBOpenArrowStyle || _startArrowStyle == DBPointYArrowStyle) && _fillStartArrow){
					[startArrow setLineWidth:_lineWidth];
					[_startArrowFillColor setFill];
					[startArrow fill];
				}
				if(_strokeStartArrow)
					[startArrow stroke];
			}
		
			if(_showEndArrow){ 
				endArrow = [path endArrowWithType:_endArrowStyle options:DBDefaultArrowOptions()];
			
				if(!(_endArrowStyle == DBOpenArrowStyle || _endArrowStyle == DBPointYArrowStyle) && _fillEndArrow){
					[endArrow setLineWidth:_lineWidth];
					[_endArrowFillColor setFill];
					[endArrow fill];
				}
				if(_strokeEndArrow){			
					[endArrow stroke];
				}                       
			}
		}else if(_strokeMode == DBImagePatternStrokeMode){
/*			if ([self leadInAndOutLengthProportion] != 0)
			{
				// set up lead in and out lengths as a proportion of path length - this will scale the image
				// proportional to length over that distance so that the effect tapers off at both ends of the path
				
				float	pathLength = [path length];
				float	lilo = pathLength * [self leadInAndOutLengthProportion];
				
				[self setLeadInLength:lilo];
				[self setLeadOutLength:lilo];
			}*/
			
			if ([self leaderDistance] > 0 )
				path = [[[path autorelease] bezierPathByTrimmingFromLength:[self leaderDistance]] retain];


			[path placeObjectsOnPathAtInterval:[self interval] factoryObject:self userInfo:NULL];
		}
		
		[path release];    
	}
	
	[NSGraphicsContext restoreGraphicsState];
	
	NSAffineTransform *at = [[NSAffineTransform alloc] init]; 
	[at translateXBy:[_shape bounds].origin.x yBy:[_shape bounds].origin.y];

	[NSGraphicsContext saveGraphicsState];
	[at concat];
	
	NSColor *textColor = [_text attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
	
	if(textColor){
		[textColor set];
	}else{           
		[_strokeColor set];
	}
	
	//NSLog(@"color attribute : %@", [_text attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL]);
	
	[_textPath fill];
	[NSGraphicsContext restoreGraphicsState];
	
	[at release];
}

-(void)strokePathShadow:(NSBezierPath *)drawPath
{
	NSColor *setColor;
	
	setColor = [[self strokeColor] retain];
	
	_strokeColor = [[NSColor colorWithDeviceWhite:0.0 alpha:0.0001] retain];
	
	[self strokePath:drawPath];
	
	[_strokeColor release];
	_strokeColor = setColor;

}
#pragma mark As part of BezierPlacement Protocol

// comes from the DrawKit Framework

- (float)rampFunction:(float) val
{
//	return val;
	// return a value in 0..1 given a value in 0..1 which is used to set the curvature of the leadin and lead out ramps
	// (for a linear ramp, return val)
	
	return 0.5 * ( 1 - cosf( (fmodf( val, 1.0 ) + _rampPhase)* pi/_rampPeriod ));
}

- (float)patternScale
{
	return m_scale;
}

- (void)setPatternScale:(float) scale
{
	NSAssert( scale > 0.0, @"scale cannot be zero or negative");
	
	m_scale = scale;
	[_shape strokeUpdated];
}

- (float)interval
{
	return m_interval;
}

- (void)setInterval:(float) interval
{
	NSAssert( interval > 0.0, @"interval cannot be zero or negative");
	
	m_interval = interval;
	[_shape strokeUpdated];
}

- (float)leaderDistance
{
	return m_leader;
}

- (void)setLeaderDistance:(float) leader
{
	m_leader = leader;
	[_shape strokeUpdated];
}

- (BOOL)normalToPath
{
	return m_normalToPath;
}

- (void)setNormalToPath:(BOOL) norml
{
	m_normalToPath = norml;
	[_shape strokeUpdated];
}

- (void)				setLeadInAndOutLengthProportion:(float) proportion
{
	m_liloProportion = proportion;
	
	if ( proportion <= 0.0 )
		m_leadInLength = m_leadOutLength = 0.0;

	[_shape strokeUpdated];
}


- (float)				leadInAndOutLengthProportion
{
	return m_liloProportion;
}

- (void)				setLeadInLength:(float) linLength
{
	NSLog(@"inLength %f",linLength);
	m_leadInLength = linLength;
	//do not update stroke here
}


- (void)				setLeadOutLength:(float) loutLength
{
	NSLog(@"outLength %f",loutLength);
	m_leadOutLength = loutLength;
	//do not update stroke here
}


- (float)				leadInLength
{
	return m_leadInLength;
}


- (float)				leadOutLength
{
	return m_leadOutLength;
}

- (BOOL)useRamp
{
	return _useRamp;
}

- (void)setUseRamp:(BOOL)flag
{
	_useRamp = flag;
	
	[_shape strokeUpdated];
}


- (float)rampPeriod
{
	return _rampPeriod;
}

- (void)setRampPeriod:(float)period
{
	_rampPeriod = LIMIT(period,0.0,1.0);
	[_shape strokeUpdated];
}

- (float)rampPhase
{
	return _rampPhase;
}

- (void)setRampPhase:(float)phase
{
	_rampPhase = LIMIT(phase,0.0,1.0);
	[_shape strokeUpdated];
}

- (id)placeObjectAtPoint:(NSPoint)p onPath:(NSBezierPath*)path position:(float)pos slope:(float)slope userInfo:(void*)userInfo
{
#pragma unused(userInfo)
//	NSLog(@"appel position %f",pos);
	NSImage* img = _patternImage;
	
	if ( img != nil )
	{
		NSAssert([NSGraphicsContext currentContext] != nil, @"no context for drawing path decorator motif");
		
		NSSize	iSize = [img size];
		
		float	leadScale = 1.0;
		
		if ( path != nil && [self useRamp] && [self rampPeriod] > 0)
		{
//			float	loLen = [path length] - m_leadOutLength;
//			
//			if ( m_leadInLength != 0 && pos < m_leadInLength )
//				leadScale = [self rampFunction:pos / m_leadInLength];
//			else if ( m_leadOutLength != 0 && pos > loLen )
//				leadScale = [self rampFunction:1.0 - ((pos - loLen) / m_leadOutLength)];
//			
//			
			
			leadScale = [self rampFunction:pos/[path length]];
			
			// if size has reduced to zero, nothing to do
			
			if ( leadScale <= 0.0 )
				return nil;
		}
			
		
		NSAffineTransform* tfm = [NSAffineTransform transform];
		
		[tfm translateXBy:p.x yBy:p.y];
		[tfm scaleXBy:[self patternScale] * leadScale yBy:[self patternScale] * -1.0 * leadScale ];
		
//		NSLog(@"lead scale %f",leadScale);
		
		if( [self normalToPath])
			[tfm rotateByRadians:-slope];
		
		[tfm translateXBy:-(iSize.width / 2) yBy:-(iSize.height / 2)];
		
		// does it really need to be drawn at all?
		
		NSRect drawnRect;
//		DBDrawingView*	cv = [[[[self shape] layer] layerController] drawingView];	// n.b. can be nil if drawing into image, etc
		
		drawnRect.origin = [tfm transformPoint:NSZeroPoint];
		NSPoint qp = [tfm transformPoint:NSMakePoint( iSize.width, iSize.height )];
		
		drawnRect = NSRectFromTwoPoints( drawnRect.origin, qp );
		
		float maxw = MAX( drawnRect.size.width, drawnRect.size.height );
		drawnRect.size.width = drawnRect.size.height = maxw * 1.4;
		drawnRect = CentreRectOnPoint( drawnRect, p );
		
//		[[NSColor blackColor] set];
		//NSFrameRectWithWidth( drawnRect, 1.0 );
		
//		if( cv == nil || [cv needsToDrawRect:drawnRect])
//		{
			[NSGraphicsContext saveGraphicsState];
			[tfm concat];
			
/*			if (( m_cache != nil ) && m_lowQuality )
			{
				CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
				CGContextDrawLayerAtPoint( context, CGPointZero, m_cache );
			}
			else if ( m_pdf != nil  )
				[m_pdf draw];
			else */
				[img drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		//[NSBezierPath fillRect:NSMakeRect(-2., -2.0, 4., 4.)];
			[NSGraphicsContext restoreGraphicsState];
//		}
	}
	return nil;
}


@end
