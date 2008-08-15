//
//  DBShapeCollectionDocument.h
//  DrawBerry
//
//  Created by Raphael Bost on 02/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBShapeCollection;

@interface DBShapeCollectionDocument : NSDocument {
	DBShapeCollection *_collection;
	
	IBOutlet NSTextField *_descriptionField;
}
- (IBAction)addCollection:(id)sender;
- (IBAction)cancel:(id)sender;
@end
