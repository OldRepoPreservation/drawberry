//
//  DBCIFilterPickerController.h
//  CoreImageFilterPicker
//
//  Created by Raphael Bost on 25/06/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBCIFilterPickerController : NSObject {
	IBOutlet NSWindow *_filterPalette;           // the filter palette (called image units)
    IBOutlet NSButton *_filterOKButton;          // the apply button, actually
    IBOutlet NSButton *_filterCancelButton;      // the cancel button
    IBOutlet NSTableView *_categoryTableView;    // the category table view
    IBOutlet NSTableView *_filterTableView;      // the filter list table view
    IBOutlet NSButton *_filterTextButton;        // the text button
    int _currentCategory;                        // the currently selected row in the category table view
    int _currentFilterRow;                       // the currently selected row in the filter table view
    NSMutableDictionary *_categories;            // a dictionary containing all filter category names and the filters that populate the category
    NSString *_filterClassname;                  // returned filter's classname from the modal filter palette (when a filter has been selected)
    
}
+ (id)sharedCIFilterPickerController;                                                               
+ (NSString *)ellipsizeField:(float)width font:(NSFont *)font string:(NSString *)label;
- (NSString *)categoryNameForIndex:(int)i;
- (NSMutableDictionary *)buildFilterDictionary:(NSArray *)names;
- (NSDictionary *)collectFilterImageOrText;
- (void)addEffect;

- (IBAction)filterOKButtonAction:(id)sender;
- (IBAction)filterCancelButtonAction:(id)sender;
@end
