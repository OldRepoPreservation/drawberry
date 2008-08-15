// EffectStack.h
// Author: Mark Zimmer
// 12/08/04
// Copyright (c) 2004 Apple Computer, Inc. All Rights Reserved.

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class CoreImageView;

@interface EffectStack : NSView  <NSCoding>
{
    CIImage *baseImage;         // a pointer to the base image in the array (generally layers[0].image
    NSMutableArray *layers;     // effect stack filter, image, text layers in an array
}

// designated init routine
- (id)init;
// effect stack layer operationsd
- (void)insertFilterLayer:(CIFilter *)filter atIndex:(int)index;
- (void)insertImageLayer:(CIImage *)image withFilename:(NSString *)filename atIndex:(int)index;
- (void)insertTextLayer:(NSString *)string withImage:(CIImage *)image atIndex:(int)index;
- (void)removeLayerAtIndex:(int)index;
- (void)removeAllLayers;
// getters
- (int)layerCount;
- (BOOL)layerEnabled:(int)index;
- (NSString *)typeAtIndex:(int)index;
- (CIFilter *)filterAtIndex:(int)index;
- (CIImage *)imageAtIndex:(int)index;
- (NSPoint)offsetAtIndex:(int)index;
- (NSString *)filenameAtIndex:(int)index;
- (NSString *)imageFilePathAtIndex:(int)index;
- (NSData *)imageFileDataAtIndex:(int)index;
- (NSString *)stringAtIndex:(int)index;
- (NSMutableDictionary *)mutableDictionaryAtIndex:(int)index;
- (CIImage *)baseImage;
- (NSString *)filterLayer:(int)index imageFilePathValueForKey:(NSString *)key;
- (NSData *)filterLayer:(int)index imageFileDataValueForKey:(NSString *)key;
// setters
- (void)setLayer:(int)index enabled:(BOOL)enabled;
- (void)setBaseImage:(CIImage *)image withFilename:(NSString *)filename andImageFilePath:(NSString *)path;
- (void)setFilterLayer:(int)index imageFilePathValue:(NSString *)path forKey:(NSString *)key;
- (void)setImageLayer:(int)index offset:(NSPoint)offset;
- (void)setImageLayer:(int)index image:(CIImage *)image andFilename:(NSString *)filename;
- (void)setImageLayer:(int)index imageFilePath:(NSString *)path;
- (void)setTextLayer:(int)index offset:(NSPoint)offset;
- (void)setTextLayer:(int)index string:(NSString *)string andImage:(CIImage *)image;
// for core image result graph from stack
- (CIImage *)coreImageResultForRect:(NSRect)bounds inputImage:(CIImage *)inputImage;
// convenience methods for preventing exceptions during evaluation and for reddening a box (alarm)
- (BOOL)filterHasMissingImage:(CIFilter *)f;
- (BOOL)hasMissingImage;
// for preset encoding
- (void)encodeValue:(id)obj forKey:(NSString *)key intoDictionary:(NSMutableDictionary *)v;
- (id)decodedValueForKey:(NSString *)key ofClass:(NSString *)classname fromDictionary:(NSDictionary *)v;
@end
