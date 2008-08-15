// ParameterView.h
// Author: Mark Zimmer
// 12/08/04
// Copyright (c) 2004 Apple Computer, Inc. All Rights Reserved.
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

// various types of data represented in a slider
typedef enum
{
    stScalar = 0,
    stAngle,
    stTime,
    stDistance,
} SliderType;

@class CoreImageView;
@class DBStackController, DBFilterStack;
@class FunHouseImageView;

@interface ParameterView : NSView
{
    CIFilter *filter;                   // filter this UI element belongs to
    NSMutableDictionary *dict;          // dictionary for text layer this slider/text view belongs to
    NSString *key;                      // key this UI element sets in filter
    CoreImageView *displayView;         // view that owns this filter and can call to update display
	DBFilterStack *filterStack;
    DBStackController *master;      // pointer back to the effect stack controller
    NSSlider *slider;                   // slider pointer, if we are a slider
    SliderType dataType;                // basic data type represented by the slider
    NSButton *checkBox;                 // check box pointer, if we are a check box
    NSColorWell *colorWell;             // color well pointer, if we are a color well
    FunHouseImageView *imageView;       // image view pointer, if we are an image view
    NSButton *pushButton;               // push button pointer (used in image layer widgets)
    NSTextField *labelTextField;        // label text field (for slider, color well, some image views)
    NSTextField *readoutTextField;      // readout text field (for sliders)
    NSTextView *textView;               // text view pointer (for text layer widgets)
    int beforeDecimal;                  // format info for slider readouts
    int afterDecimal;                   // format info for slider readouts
    float lastFloatValue;               // for slider: last floating point value shown
    // for transform
    NSSlider *scaleSlider;
    NSSlider *angleSlider;
    NSSlider *stretchSlider;
    NSSlider *skewSlider;
    NSTextField *scaleLabelTextField;
    NSTextField *angleLabelTextField;
    NSTextField *stretchLabelTextField;
    NSTextField *skewLabelTextField;
    NSTextField *scaleReadoutTextField;
    NSTextField *angleReadoutTextField;
    NSTextField *stretchReadoutTextField;
    NSTextField *skewReadoutTextField;
    SliderType scaleDataType;
    SliderType angleDataType;
    SliderType stretchDataType;
    SliderType skewDataType;
    float lastScaleFloatValue;
    float lastAngleFloatValue;
    float lastStretchFloatValue;
    float lastSkewFloatValue;
    BOOL usingNSAffineTransform;
    // for naked CIVector widgets
    NSTextField *readout1TextField;
    NSTextField *readout2TextField;
    NSTextField *readout3TextField;
    NSTextField *readout4TextField;
}

// convenience methods we export
+ (CIImage *)CIImageWithNSImage:(NSImage *)image;
+ (NSString *)ellipsizeField:(float)width font:(NSFont *)font string:(NSString *)label;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)readoutTextFieldChanged:(id)sender;
- (IBAction)colorWellChanged:(id)sender;

// for filter inspection
- (void)addSliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;
- (void)addCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;
- (void)addColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;
- (void)addImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;
- (void)addTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;
- (void)addVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;
- (void)addOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v master:(DBFilterStack *)m;

// for image inspection
//- (void)addImageWellForImage:(CIImage *)im tag:(int)tag displayView:(CoreImageView *)v master:(DBStackController *)m;

// for text inspection 
//- (void)addTextViewForString:(NSMutableDictionary *)d key:(NSString *)k displayView:(CoreImageView *)v master:(DBStackController *)m;
//- (void)addSliderForText:(NSMutableDictionary *)d key:(NSString *)k lo:(float)lo hi:(float)hi displayView:(CoreImageView *)v master:(DBStackController *)m;

@end

@interface FunHouseImageView : NSImageView
    {
    NSString *_filePath;
    }

- (void)setFilePath:(NSString *)path;
- (NSString *)filePath;
@end

NSString *unInterCap(NSString *s);
