//
//  DBDrawingView+TextEditing.h
//  DrawBerry
//
//  Created by Raphael Bost on 27/02/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBDrawingView.h"

@interface DBDrawingView (TextEditing)
- (void)addTextView:(NSTextView *)textView;
- (void)removeTextView:(NSTextView *)textView;
@end
