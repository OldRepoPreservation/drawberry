//
//  DBText.h
//  DrawBerry
//
//  Created by Raphael Bost on 27/02/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBRectangle.h"

@interface DBText : DBRectangle {
	NSTextStorage*		_text;						// the text
	NSTextView*			_editor;					// when editing, a reference to the editor view
	NSRect				_textRect;					// rect of the text relative to the final shape
	int					_vertAlign;					// vertical text alignment
    int _vertPos;
	NSTextAlignment _textAlignment;
}

- (void)setText:(id) newText;

- (NSTextView*) editText:(NSTextStorage*) text inRect:(NSRect) rect delegate:(id) del;
- (int)textVerticalPositon;
- (void)setTextVerticalPositon:(int)newTextVerticalPositon;

- (NSTextAlignment)textAlignment;
- (void)setTextAlignment:(NSTextAlignment)newTextAlignment;
@end
