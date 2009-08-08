//
//  DBShapeCollectionDocument.h
//  DrawBerry
//
//  Created by Raphael Bost on 02/08/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
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
