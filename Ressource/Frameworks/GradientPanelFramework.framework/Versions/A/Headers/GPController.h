//
//  GPController.h
//  GradientPanel
//
//  Created by Raphael Bost on 27/08/08.
//  Copyright 2008 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPGradientSlider.h"
#import "GPGradientView.h"
#import "GPGradientPanel.h"

#import "CTGradient.h"

@interface GPController : NSObject {
	CTGradient *_gradient;
	
	IBOutlet GPGradientView *_grdView;
	IBOutlet GPGradientSlider *_grdLine;
	IBOutlet NSSegmentedControl *_typeChooser;
	IBOutlet NSSlider *_angleSlider;
	
	IBOutlet GPGradientPanel *_gpController;
	
	CGFloat _angle;
	GPGradientType _type;
}

- (CTGradient *)gradient;
- (void)setGradient:(CTGradient *)grd;
- (void)setGradient:(CTGradient *)grd updateAll:(BOOL)flag;
- (CGFloat)angle;
- (void)setAngle:(CGFloat)newAngle;
- (GPGradientType)type;
- (void)setGradientType:(GPGradientType)gt;

- (IBAction)takeAngleValueFrom:(id)sender;
- (IBAction)takeTypeFrom:(id)sender;
- (void)updateViews;

- (void)writeGradientToPasteboard:(NSPasteboard *)pb;
- (BOOL)readGradientFromPasteboard:(NSPasteboard *)pb;
@end
