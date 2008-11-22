//
//  DBText.m
//  DrawBerry
//
//  Created by Raphael Bost on 27/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DBText.h"

static NSLayoutManager*		sharedDrawingLayoutManager()
{
    // This method returns an NSLayoutManager that can be used to draw the contents of a GCTextShape.
	// The same layout manager is used for all instances of the class
	
    static NSLayoutManager *sharedLM = nil;
    
	if ( sharedLM == nil )
	{
        NSTextContainer*	tc = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
		NSTextView*			tv = [[NSTextView alloc] initWithFrame:NSZeroRect];
        
        sharedLM = [[NSLayoutManager alloc] init];
		
		[tc setTextView:tv];
		[tv release];
		
        [tc setWidthTracksTextView:NO];
        [tc setHeightTracksTextView:NO];
        [sharedLM addTextContainer:tc];
        [tc release];
		
		[sharedLM setUsesScreenFonts:NO];
    }
    return sharedLM;
}

@implementation DBText

- (id)init
{
	self = [super init];
	
	[self setText:@"Hello World"];
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	            	
	_text = [[decoder decodeObjectForKey:@"Text"] retain];
	_textAlignment = [decoder decodeIntForKey:@"Text Alignment"];
	_vertAlign = [decoder decodeIntForKey:@"Vertical Alignment"];

	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:_text forKey:@"Text"];
	[encoder encodeInt:_textAlignment forKey:@"Text Alignment"];
	[encoder encodeInt:_vertAlign forKey:@"Vertical Alignment"];
}

- (void)dealloc
{
	[_text release];
	
	[super dealloc];
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(DBDrawingView *)view
{
	BOOL result = [super createWithEvent:theEvent inView:view];
	
	[[self stroke] setStrokeMode:DBNoStrokeMode];
	
	return result;
}

- (NSTextStorage *)text
{
	return _text;
}

- (void)setText:(id) newText
{
    // sets the object's text to the passed text. You can pass any sort of string - NSString, NSAttributedString, NSTextStorage or any mutable
	// variety thereof. If the string is attributed, the object adopts the new attributes if the style doesn't have text attributes currently.
	
	if(!newText){
		[_text release];
		_text = nil;
	}
	if ( newText != _text)
	{
        if ( _text == nil )
			_text = [[NSTextStorage alloc] init];
		
		NSAttributedString *contentsCopy = [[NSAttributedString alloc] initWithAttributedString:_text];
//        [[[self undoManager] prepareWithInvocationTarget:self] setText:contentsCopy];
        
		[contentsCopy release];
             
		if ([newText isKindOfClass:[NSTextStorage class]]){
			[newText retain];
			[_text release];
			_text = newText;
			
			
        }else if ([newText isKindOfClass:[NSAttributedString class]])
            [_text replaceCharactersInRange:NSMakeRange(0, [_text length]) withAttributedString:newText];
		else
            [_text replaceCharactersInRange:NSMakeRange(0, [_text length]) withString:newText];

    }
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
}

- (int)textVerticalPositon
{
	return _vertPos;
}

- (void)setTextVerticalPositon:(int)newTextVerticalPositon
{
	_vertPos = newTextVerticalPositon;
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES]; 	
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
	[[[self layer] layerController] updateDependentLayers:[self layer]];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES]; 	
}   

/*- (void)displayEditingKnobs
{
	[super displayEditingKnobs];
	
	if(!_editor){ 
		NSLog(@"show");
		_editor = [self editText:_text inRect:[self bounds] delegate:self];
		
		[[[_layer layerController] drawingView] addTextView:_editor];
	}
}
*/

- (void)displayEditingKnobs
{
	
}
/*- (void)displaySelectionKnobs
{
	[super displaySelectionKnobs];
	
	if(_editor){
		[_editor setNeedsDisplay:YES];
		[_editor removeFromSuperview];
		[_editor release];
		_editor = nil;		

		[_layer updateRenderInView:nil];
		[[[self layer] layerController] updateDependentLayers:[self layer]];
	}
}
*/
- (void)setIsEditing:(BOOL)flag
{
	[super setIsEditing:flag];
	
	if(flag && !_editor){ 
		_editor = [self editText:_text inRect:[self bounds] delegate:self];
		
		[[[_layer layerController] drawingView] addTextView:_editor];
		[self setText:nil];
	}else if(!flag && 	_editor){     
			[self setText:[_editor textStorage]];

			// [_editor setNeedsDisplay:YES];
			// [_editor removeFromSuperview]; 
			
			[[[_layer layerController] drawingView] removeTextView:_editor];
			[_editor release];
			_editor = nil;		

			[_layer updateRenderInView:nil];
			[[[self layer] layerController] updateDependentLayers:[self layer]];
	}
} 
- (void) drawText                         
{
	NSSize osize = [self bounds].size;
	          
	NSTextStorage *contents = _text;

	if ([_text length] > 0)
	{
		
		NSLayoutManager *lm = sharedDrawingLayoutManager();
		NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];

		NSRange		glyphRange;
		NSRange		grange;
//		NSRect		frag;

		
		NSAffineTransform *af = [NSAffineTransform transform];
		NSAffineTransform *translate = [NSAffineTransform transform];
		NSAffineTransform *rotate = [NSAffineTransform transform];
//		NSPoint originPoint = [_shape bounds].origin;
 		NSPoint textOrigin;

 		[rotate rotateByDegrees:[self rotation]];
		[translate translateXBy:[self rotationCenter].x yBy:[self rotationCenter].y];

		[af appendTransform:rotate];
		[af appendTransform:translate];
		
		[NSGraphicsContext saveGraphicsState];
		[af concat];

		[tc setContainerSize:osize];
		[contents addLayoutManager:lm];

		// Force layout of the text and find out how much of it fits in the container.

		glyphRange = [lm glyphRangeForTextContainer:tc];

		// because of the object transform applied, draw the text at the origin

		if (glyphRange.length > 0)
		{
			grange = glyphRange;

			//NSPoint textOrigin = [self textOriginForSize:textSize objectSize:osize];

			textOrigin = NSZeroPoint;
			textOrigin.x = - ([self bounds].size.width)/2;
			switch(_vertPos)
			{
				case 0:
 					textOrigin.y = -([self bounds].size.height)/2;
   					break;

				case 1:
					break;

				case 2:
					textOrigin.y = [self bounds].size.height/2 -[lm usedRectForTextContainer:tc].size.height;
					break;
			}

			[lm drawGlyphsForGlyphRange:grange atPoint:textOrigin];
		}
		[NSGraphicsContext restoreGraphicsState];
//		[contents release];
	}
}

- (void)drawInView:(DBDrawingView *)view rect:(NSRect)rect
{
	[super drawInView:view rect:rect];
	
	[self drawText];
}

- (NSTextView*) editText:(NSTextStorage*) text inRect:(NSRect) rect delegate:(id) del
{
	// when an object in the drawing wishes to allow the user to edit some text, it can use this utility to set up the editor. This
	// creates a subview for text editing with the nominated text and the bounds rect given within the drawing. The text is installed,
	// selected and activated. User actions then edit that text. When done, call endTextEditing. To get the text edited, call editedText
	// before ending the mode. You can only set one item at a time to be editable.
	
	NSTextView *textEditView;
	
	textEditView = [[NSTextView alloc] initWithFrame:rect];
	NSLayoutManager*	lm = [textEditView layoutManager];
	
	NSTextStorage *ts = [[NSTextStorage alloc] initWithAttributedString:text];
	
//	[lm setTextStorage:text];
	[lm replaceTextStorage:ts];
	
//	[textEditView setString:[text string]];
	
	[textEditView setUsesRuler:NO];

	[textEditView setDrawsBackground:NO];
	[textEditView setFieldEditor:NO];
	[textEditView setSelectedRange:NSMakeRange( 0, [text length])];
//    [textEditView setAllowsUndo:YES];
	[textEditView setDelegate:del];

	[textEditView setNeedsDisplay:YES];
	
	[ts release];	
	return textEditView;
}

@end
