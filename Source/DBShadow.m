//
//  DBShadow.m
//  DrawBerry
//
//  Created by Raphael Bost on 23/08/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBShadow.h"
#import "DBShape.h"

@implementation DBShadow

+ (void)initialize
{
	[self exposeBinding:@"shadowOffsetWidth"];
	[self exposeBinding:@"shadowOffsetHeight"];
	[self exposeBinding:@"shadowBlurRadius"];
	[self exposeBinding:@"shadowColor"];
}

- (id)init
{
	self = [super init];
	
	[self setShadowOffset:NSMakeSize(10.0,-10.0)];
	[self setShadowBlurRadius:2.0];
	[self setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
	[self setEnabled:NO];
	
	return self;
}

- (id)initWithShape:(DBShape *)shape
{
	self = [self init];
	
	_shape = shape;            
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	           
	_enabled = [decoder decodeBoolForKey:@"Enabled"];            
	
	return self;
}
    
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeBool:_enabled forKey:@"Enabled"];
}                                                   

- (id)copyWithZone:(NSZone *)zone
{
    DBShadow *shadow = [super copyWithZone:zone];
    
    [shadow setEnabled:[self enabled]];
    
    return shadow;
}

- (void)set
{
	if(_enabled){
		[super set];
	}
}

- (BOOL)enabled
{
	return _enabled;
}

- (void)setEnabled:(BOOL)newEnabled
{
	_enabled = newEnabled;
	[_shape strokeUpdated];
}

- (void)setShadowOffset:(NSSize)newSetShadowOffset
{
	[super setShadowOffset:newSetShadowOffset];
	[self setShadowOffsetWidth:_shadowOffset.width];
	[self setShadowOffsetHeight:_shadowOffset.height];
}

- (float)shadowOffsetWidth
{
	return _shadowOffset.width;
}

- (void)setShadowOffsetWidth:(float)newShadowOffsetWidth
{
	if(newShadowOffsetWidth != _shadowOffset.width){
		[self setShadowOffset:NSMakeSize(newShadowOffsetWidth, _shadowOffset.height)];
		[_shape strokeUpdated];
	}
}

- (void)reverseShadowOffsetHeight
{
	[self setShadowOffset:NSMakeSize(_shadowOffset.width, -_shadowOffset.height)];
} 
- (float)shadowOffsetHeight
{
	return _shadowOffset.height;
}

- (void)setShadowOffsetHeight:(float)newShadowOffsetHeight
{
	if(newShadowOffsetHeight != _shadowOffset.height){
		[self setShadowOffset:NSMakeSize(_shadowOffset.width, newShadowOffsetHeight)];
		[_shape strokeUpdated];
	}
}

- (void)setShadowBlurRadius:(float)newShadowBlurRadius
{   
	if(newShadowBlurRadius != _shadowBlurRadius){
		[super setShadowBlurRadius:newShadowBlurRadius];
		[_shape strokeUpdated];
	}
}

- (void)setShadowColor:(NSColor *)color
{   
	if(![_shadowColor isEqualTo:color]){
	  	[super setShadowColor:color];
		[_shape strokeUpdated];
	}
}

- (DBShape *)shape
{
	return _shape;
}

- (void)setShape:(DBShape *)newShape
{
	_shape = newShape;
   	[_shape strokeUpdated];
} 

@end
