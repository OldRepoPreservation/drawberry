//
//  DBToolMatrix.h
//  DrawBerry
//
//  Created by Raphael Bost on 12/07/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBToolMatrix : NSMatrix {
	BOOL _double;
}                
- (void)toolDidEnd:(id)sender;

@end
