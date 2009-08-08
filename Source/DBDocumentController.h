//
//  DBDocumentController.h
//  DrawBerry
//
//  Created by Raphael Bost on 26/04/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBDocumentController : NSDocumentController {
	IBOutlet NSPanel *_newPanel;
	IBOutlet NSPopUpButton *_templateChooser;
	IBOutlet NSTextField *_widthField;
	IBOutlet NSTextField *_heightField;
	
	float _docWidth, _docHeight;
}
- (IBAction)changeSize:(id)sender;
- (IBAction)changeTemplate:(id)sender;
- (IBAction)create:(id)sender;

- (float)documentWidth;
- (float)documentHeight;

- (void)updateTemplateMenuChooser;
@end
