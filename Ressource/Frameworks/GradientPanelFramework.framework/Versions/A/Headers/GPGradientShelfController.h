//
//  GPGradientShelfController.h
//  GradientPanel
//
//  Created by Raphael Bost on 26/10/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DBMatrix.h"

@interface GPGradientShelfController : NSObject {
	NSMutableArray *_gradients;
	IBOutlet DBMatrix *_matrix;
}
- (void)readGradientShelf;
- (void)writeGradientShelf;
@end
