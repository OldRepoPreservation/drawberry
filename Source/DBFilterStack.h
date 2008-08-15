//
//  DBFilterStack.h
//  DrawBerry
//
//  Created by Raphael Bost on 24/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
 
#import <QuartzCore/QuartzCore.h>
#import "DBCIFilterPoint.h"

@class EffectStack;
@class FilterView;
@class DBLayer;

extern NSString *DBFilterStackDidChangeNotification;

@interface DBFilterStack : NSObject <NSCoding>{
	EffectStack	*_effects; 
	NSMutableArray *_filterBoxes;
	DBLayer *_layer;               
	
	CIFilterPoint *_filterPoints;
	int _filterPointsCount;   
}                  
- (EffectStack *)effects;
- (void)updateBoxes;
- (NSArray *)boxes;
- (void)setChanges;
- (void)filterChange;
- (DBLayer *)layer;
- (void)setLayer:(DBLayer *)aValue;

- (void)insertFilter:(CIFilter *)f atIndex:(NSNumber *)index;
- (void)removeFilterAtIndex:(NSNumber *)index;
- (void)setAutomaticDefaults:(CIFilter *)f atIndex:(int)index;
- (FilterView *)createUIForFilter:(CIFilter *)f index:(int)index;
- (IBAction)enableCheckBoxAction:(id)sender; 
- (IBAction)plusButtonAction:(id)sender;
- (IBAction)minusButtonAction:(id)sender;
- (void)addFilter:(id)sender;
- (IBAction)resetButtonAction:(id)sender;
- (FilterView *)createUIForFilter:(CIFilter *)f index:(int)index;
- (BOOL)effectStackFilterHasMissingImage:(CIFilter *)f;
- (void)registerFilterLayer:(CIFilter *)filter key:(NSString *)key imageFilePath:(NSString *)path;
- (NSString *)imageFilePathForFilterLayer:(CIFilter *)filter key:(NSString *)key;

- (void)setFilter:(CIFilter *)f value:(id)val forKey:(NSString *)key;

- (int)filterPointsCount;
- (CIFilterPoint *)filterPoints;
- (void)updateFilterPoints;
- (CIFilterPoint)filterPointUnderPoint:(NSPoint)p;
- (CIImage *)applyFiltersToImage:(CIImage *)inputImage;
@end
