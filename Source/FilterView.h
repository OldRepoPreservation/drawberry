// FilterView.h
// Author: Mark Zimmer
// 12/08/04
// Copyright (c) 2004 Apple Computer, Inc. All Rights Reserved.
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "EffectStackController.h"
#import "DBFilterStack.h"

@class CoreImageView;

// type of widget last added
typedef enum
{
    ctNone = 0,
    ctSlider,
    ctColorWell,
    ctCheckBox,
    ctImageWell,
    ctTransform,
    ctVector,
    ctTextView,
    ctOffset,
} ControlType;


@interface EffectStackBox : NSView
{
    CIFilter *filter;
    DBFilterStack *master;
	BOOL	_collapsed;
	NSRect _rect;
}

- (void)drawRect:(NSRect)r;
- (void)setFilter:(CIFilter *)f;
- (void)setMaster:(DBFilterStack *)m;
- (BOOL)collapsed;
- (void)setCollapsed:(BOOL)newCollapsed;

@end

@interface FilterView : EffectStackBox
{
    int tag;                                // tag: it's the layer index!
    int controlLeftPosition;                // state used for packing widgets
    int controlTopPosition;                 // state used for packing widgets
    int colorWellOffset;                    // state used for packing widgets
    ControlType lastControlType;            // last control type added (for packing widgets properly)
    NSTextField *filterNameField;           // text field for showing filter name (image name, text)
    NSButton *plusbutton;                   // plus button: allows user to create a new layer after this one
    NSButton *minusbutton;                  // minus button: allows user to delete this layer
    NSButton *checkBox;                     // check box: for enabling/disabling the layer
}

// for computing size of box beforehand
- (void)tryFilterHeader:(CIFilter *)filter;
- (void)trySliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)tryCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)tryColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)tryImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)tryTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)tryVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)tryOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;

// for populating the box with controls
- (void)addFilterHeader:(CIFilter *)filter tag:(int)index enabled:(BOOL)enabled;
- (void)addSliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)addCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)addColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)addImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)addTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)addVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;
- (void)addOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(NSView *)v;

// image layers
//- (void)tryImageHeader:(CIImage *)im;
//- (void)addImageHeader:(CIImage *)im filename:(NSString *)filename tag:(int)index enabled:(BOOL)enabled;
//- (void)tryImageWellForImage:(CIImage *)im tag:(int)tag displayView:(CoreImageView *)v;
//- (void)addImageWellForImage:(CIImage *)im tag:(int)tag displayView:(CoreImageView *)v;

// text layers
//- (void)tryTextHeader:(NSString *)string;
//- (void)addTextHeader:(NSString *)string tag:(int)index enabled:(BOOL)enabled;
//- (void)tryTextViewForString;
//- (void)addTextViewForString:(NSMutableDictionary *)d key:(NSString *)key displayView:(CoreImageView *)v;
//- (void)trySliderForText;
//- (void)addSliderForText:(NSMutableDictionary *)d key:(NSString *)key lo:(float)lo hi:(float)hi displayView:(CoreImageView *)v;

// trim box after adding UI
- (void)trimBox;
- (void)setTag:(int)index;

@end
