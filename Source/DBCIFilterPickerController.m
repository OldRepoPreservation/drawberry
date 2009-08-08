//
//  DBCIFilterPickerController.m
//  CoreImageFilterPicker
//
//  Created by Raphael Bost on 25/06/07.
//  Copyright 2007 Raphael Bost. All rights reserved.
//

#import "DBCIFilterPickerController.h"

#import <QuartzCore/QuartzCore.h>

static DBCIFilterPickerController *_sharedCIFilterPickerController = nil;

@implementation DBCIFilterPickerController

+ (id)sharedCIFilterPickerController
{
	if (!_sharedCIFilterPickerController)
        _sharedCIFilterPickerController = [[DBCIFilterPickerController allocWithZone:[self zone]] init];
    return _sharedCIFilterPickerController;
}

+ (NSString *)ellipsizeField:(float)width font:(NSFont *)font string:(NSString *)label
{
    BOOL first;
    int length, columnwidth, stringwidth;
    NSMutableString *label2;
    
    // determine if we need to ellipsize
    columnwidth = width - 5;
	stringwidth = [label sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]].width;
	
    if (stringwidth <= columnwidth)
        return label;
    label2 = [label mutableCopyWithZone:nil];
    first = YES;
    while (stringwidth > columnwidth)
    {
        length = [label2 length];
        if (first)
            [label2 replaceCharactersInRange:NSMakeRange(length-1, 1) withString:@"..."];
        else
            [label2 replaceCharactersInRange:NSMakeRange(length-4, 4) withString:@"..."]; // must include ellipsis now
        first = NO;
		stringwidth = [label sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]].width;
    }
    return [label2 copy];
}
 
// build the filter list (enumerates all filters)
- (void)_loadFilterListIntoInspector
{
    NSString *cat;
    NSArray *attrs;
    NSMutableArray *all;
    int i, m;

    // here's a list of all categories
    attrs = [NSArray arrayWithObjects:
//      kCICategoryGeometryAdjustment, // no geometry adjustment
      kCICategoryDistortionEffect,
      kCICategoryBlur,
      kCICategorySharpen,
      kCICategoryColorAdjustment,
      kCICategoryColorEffect,
      kCICategoryStylize,
      kCICategoryHalftoneEffect,
      kCICategoryTileEffect,
      kCICategoryGenerator,
      kCICategoryGradient,
//      kCICategoryTransition,   // no transition
//      kCICategoryCompositeOperation, // no compositing
      nil];
    // call to load all plug-in image units
    [CIPlugIn loadAllPlugIns];
    // enumerate all filters in the chosen categories
    m = [attrs count];
    for (i = 0; i < m; i++)
    {
        // get this category
        cat = [attrs objectAtIndex:i];
        // make a list of all filters in this category
        all = [NSMutableArray arrayWithArray:[CIFilter filterNamesInCategory:cat]];
        // make this category's list of approved filters
        [_categories setObject:[self buildFilterDictionary:all] forKey:[CIFilter localizedNameForCategory:cat]];
    }
    _currentCategory = 0;
    _currentFilterRow = 0;
    // load up the filter list into the table view
    [_filterTableView reloadData];
}

// return the category name for the category index - used by filter palette category table view
- (NSString *)categoryNameForIndex:(int)i
{
    NSString *s;

    switch (i)
        {
    // case 0:
    //     s = [CIFilter localizedNameForCategory:kCICategoryGeometryAdjustment];
    //     break;
    case 0:
        s = [CIFilter localizedNameForCategory:kCICategoryDistortionEffect];
        break;
    case 1:
        s = [CIFilter localizedNameForCategory:kCICategoryBlur];
        break;
    case 2:
        s = [CIFilter localizedNameForCategory:kCICategorySharpen];
        break;
    case 3:
        s = [CIFilter localizedNameForCategory:kCICategoryColorAdjustment];
        break;
    case 4:
        s = [CIFilter localizedNameForCategory:kCICategoryColorEffect];
        break;
    case 5:
        s = [CIFilter localizedNameForCategory:kCICategoryStylize];
        break;
    case 6:
        s = [CIFilter localizedNameForCategory:kCICategoryHalftoneEffect];
        break;
    case 7:
        s = [CIFilter localizedNameForCategory:kCICategoryTileEffect];
        break;
    case 8:
        s = [CIFilter localizedNameForCategory:kCICategoryGenerator];
        break;
    case 9:
        s = [CIFilter localizedNameForCategory:kCICategoryGradient];
        break;
    // case 11:
    //     s = [CIFilter localizedNameForCategory:kCICategoryTransition];
    //     break;
    // case 12:
    //     s = [CIFilter localizedNameForCategory:kCICategoryCompositeOperation];
    //     break;
    default:
        s = @"";
        break;
        }
    return s;
    }

// build a dictionary of approved filters in a given category for the filter inspector
- (NSMutableDictionary *)buildFilterDictionary:(NSArray *)names
{
    BOOL inspectable;
    NSDictionary *attr, *parameter;
    NSArray *inputKeys;
    NSEnumerator *enumerator;
    NSMutableDictionary *td, *catfilters;
    NSString *classname, *classstring, *key, *typestring;
    CIFilter *filter;
    int i;

    catfilters = [NSMutableDictionary dictionary];
    for (i = 0; i < [names count]; i++)
    {
        // load the filter class name
        classname = [names objectAtIndex:i];
        // create an instance of the filter
        filter = [CIFilter filterWithName:classname];
        if (filter != nil)
        {
            // search the filter for any input parameters we can't inspect
            inspectable = YES;
            attr = [filter attributes];
            inputKeys = [filter inputKeys];
            // enumerate all input parameters and generate their UI
            enumerator = [inputKeys objectEnumerator];
            while ((key = [enumerator nextObject]) != nil) 
            {
                parameter = [attr objectForKey:key];
                classstring = [parameter objectForKey:kCIAttributeClass];
                if ([classstring isEqualToString:@"CIImage"]
                  || [classstring isEqualToString:@"CIColor"]
                  || [classstring isEqualToString:@"NSAffineTransform"]
                  || [classstring isEqualToString:@"NSNumber"])
                    continue; // all inspectable
                else if ([classstring isEqualToString:@"CIVector"])
                {
                    // check for a vector with no attributes
                    typestring = [parameter objectForKey:kCIAttributeType];
                    if (typestring != nil
                      && ![typestring isEqualToString:kCIAttributeTypePosition]
                      && ![typestring isEqualToString:kCIAttributeTypeRectangle]
                      && ![typestring isEqualToString:kCIAttributeTypePosition3]
                      && ![typestring isEqualToString:kCIAttributeTypeOffset])
                        inspectable = NO;
                }
                else
                    inspectable = NO;
            }
            if (!inspectable)
                continue; // if we can't inspect it, it's not approved and must be omitted from the list
            // create a dictionary for the filter with filter's class name
            td = [NSMutableDictionary dictionary];
            [td setObject:classname forKey:kCIAttributeClass];
            // set it as the value for a key which is the filter's localized name
            [catfilters setObject:td forKey:[CIFilter localizedNameForFilterName:classname]];
        }
        else
            NSLog(@" could not create '%@' filter", classname);
    }
    return catfilters;
}


// this method brings up the "image units palette" (we call it the filter palette) - and it also has buttons for images and text layers
- (NSDictionary *)collectFilterImageOrText
{
    int i;
    CIImage *im;
    NSString *path;
    NSOpenPanel *op;
    
    // when running the filter palette, if a filter is chosen (as opposed to an image or text) then filterClassname returns the
    // class name of the chosen filter
    [_filterClassname release];
    _filterClassname = nil;
    // load the nib for the filter palette
    [NSBundle loadNibNamed:@"DBFilterPalette" owner:self];
    // set up the categories data structure, that enumerates all filters for use by the filter palette
    if (_categories == nil)
    {
        _categories = [[NSMutableDictionary alloc] init];
        [self _loadFilterListIntoInspector];
    }
    else
        [_filterTableView reloadData];
    // set up the usual target-action stuff for the filter palette
    [_filterTableView setTarget:self];
    [_filterTableView setDoubleAction:@selector(tableViewDoubleClick:)];
    [_filterOKButton setEnabled:NO];
    // re-establish the current position in the filters palette
    [_categoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_currentCategory] byExtendingSelection:NO];
    [_filterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_currentFilterRow] byExtendingSelection:NO];
    // run the modal filter palette now
    i = [NSApp runModalForWindow:_filterPalette];
    [_filterPalette close];
    if (i == 100)
        // Apply
        // create the filter layer dictionary
        return [NSDictionary dictionaryWithObjectsAndKeys:@"filter", @"type", [CIFilter filterWithName:_filterClassname], @"filter", nil];
    else if (i == 101)
        // Cancel
        return nil;
    else if (i == 102)
    {
        // Image
        // use the open panel to open an image
        op = [NSOpenPanel openPanel];
        [op setAllowsMultipleSelection:NO];
        [op setCanChooseDirectories:NO];
        [op setResolvesAliases:YES];
        [op setCanChooseFiles:YES];
        // run the open panel with the allowed types
        int j = [op runModalForTypes:[NSArray arrayWithObjects:@"jpg", @"jpeg", @"tif", @"tiff", @"png", @"crw", @"cr2", @"raf", @"mrw", @"nef", @"srf", @"exr", nil]];
        if (j == NSOKButton)
        {
        
            // get image from open panel
            path = [[op filenames] objectAtIndex:0];
            im = [[[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
            // create the image layer dictionary
            return [NSDictionary dictionaryWithObjectsAndKeys:@"image", @"type", im, @"image", [path lastPathComponent], @"filename", path, @"imageFilePath", nil];
        }
        else if (j == NSCancelButton)
            return nil;
    }
    else if (i == 103)
        // Text
        // create the text layer dictionary
        return [NSDictionary dictionaryWithObjectsAndKeys:@"text", @"type", @"text", @"string", [NSNumber numberWithFloat:10.0], @"scale", nil];
    return nil;
}

- (int)numberOfRowsInTableView:(NSTableView *)tv
{
    int count;
    NSString *s;
    NSDictionary *dict;
    NSArray *filterNames;
    
    switch ([tv tag])
    {
    case 0:
        // category table view
        count = 13 - 3;
        break;
    case 1:
        // filter table view
        s = [self categoryNameForIndex:_currentCategory];
        // use category name to get dictionary of filter names
        dict = [_categories objectForKey:s];
        // create an array
        filterNames = [dict allKeys];
        // return number of filters in this category
        count = [filterNames count];
        break;
    }
    return count;
}

static int stringCompare(id o1, id o2, void *context)
{
    NSString *str1, *str2;
    
    str1 = o1;
    str2 = o2;
    return [str1 compare:str2];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(int)row
{
    NSString *s;
    NSDictionary *dict;
    NSArray *filterNames;
    NSTextFieldCell *tfc;
	
    switch ([tv tag])
    {
    case 0:
        // category table view
        s = [self categoryNameForIndex:row];
        tfc = [tc dataCell];
        // handle names that are too long by ellipsizing the name
        s = [[self class] ellipsizeField:[tc width] font:[tfc font] string:s];
        break;
    case 1:
        // filter table view
        // we need to maintain the filter names in a sorted order.
        s = [self categoryNameForIndex:_currentCategory];
        // use label (category name) to get dictionary of filter names
        dict = [_categories objectForKey:s];
        // create an array of the sorted names (this is inefficient since we don't cache the sorted array)
        filterNames = [[dict allKeys] sortedArrayUsingFunction:stringCompare context:nil];
        // return filter name
        s = [filterNames objectAtIndex:row];
        tfc = [tc dataCell];
        // handle names that are too long by ellipsizing the name
        s = [[self class] ellipsizeField:[tc width] font:[tfc font] string:s];
        break;
    }
    return s;
}

// this is called when we select a filter from the list
- (void)addEffect
{
    int row;
    NSTableView *tv;
    NSDictionary *dict, *td;
    NSArray *filterNames;
    
    // get current category item
    tv = _filterTableView;
    // decide current filter name from selected row (or none selected) in the filter name list
    row = [tv selectedRow];
    if (row == -1)
    {
        [_filterClassname release];
        _filterClassname = nil;
        [_filterOKButton setEnabled:NO];
        return;
    }
    // use label (category name) to get dictionary of filter names
    dict = [_categories objectForKey:[self categoryNameForIndex:_currentCategory]];
    // create an array of all filter names for this category
    filterNames = [[dict allKeys] sortedArrayUsingFunction:stringCompare context:nil];
    // return filter name
    td = [dict objectForKey:[filterNames objectAtIndex:row]];
    // retain the name in filterClassname for use outside the modal
    [_filterClassname release];
    _filterClassname = [[td objectForKey:kCIAttributeClass] retain];
    // enable the apply button
    [_filterOKButton setEnabled:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int row;
    NSTableView *tv;

    tv = [aNotification object];
    row = [tv selectedRow];
    switch ([tv tag])
    {
    case 0:
        // category table view
        // select the category
        _currentCategory = row;
        // reload the filter table based on the current category
        [_filterTableView reloadData];
        [_filterTableView deselectAll:self];
        [_filterTableView noteNumberOfRowsChanged];
        break;
    case 1:
        // filter table view
        // select a filter
        // add an effect to current effects list
        _currentFilterRow = row;
        [self addEffect];
        break;
    }
}

// if we see a double-click in the filter list, it's like hitting apply
- (IBAction)tableViewDoubleClick:(id)sender
{
    [NSApp stopModalWithCode:100];
}


// handle the filter palette apply button
- (IBAction)filterOKButtonAction:(id)sender
{
    // signal to apply filter
    [NSApp stopModalWithCode:100];
}

// handle the filter palette cancel button
- (IBAction)filterCancelButtonAction:(id)sender
{
    // signal cancel
    [NSApp stopModalWithCode:101];
}

@end
