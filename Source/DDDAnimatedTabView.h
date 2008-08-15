//
//  DDDAnimatedTabView.h
//  DockDockDock
//
//  Created by Raphael Bost on 04/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef CORE_GRAPHICS_SERVICES_H
#define CORE_GRAPHICS_SERVICES_H

typedef int CGSWindow; /* Note that CGS can retrieve a particular window's CGSConnection automatically, given a CGSWindow, but many functions do not do this - unless explicitly stated, all CGSConnection arguments must be provided and valid */
typedef int CGSConnection;

typedef enum _CGSTransitionType {
    CGSNone = 0,    // No transition effect.
    CGSFade,        // Cross-fade.
    CGSZoom,        // Zoom/fade towards us.
    CGSReveal,      // Reveal new desktop under old.
    CGSSlide,       // Slide old out and new in.
    CGSWarpFade,    // Warp old and fade out revealing new.
    CGSSwap,        // Swap desktops over graphically.
    CGSCube,        // The well-known cube effect.
    CGSWarpSwitch   // Warp old, switch and un-warp.
} CGSTransitionType;

typedef enum _CGSTransitionOption {
    CGSDown,                // Old desktop moves down.
    CGSLeft,                // Old desktop moves left.
    CGSRight,               // Old desktop moves right.
    CGSInRight,             // CGSSwap: Old desktop moves into screen, 
                            //                      new comes from right.
    CGSBottomLeft = 5,      // CGSSwap: Old desktop moves to bl,
                            //                      new comes from tr.
    CGSBottomRight,         // Old desktop to br, New from tl.
    CGSDownTopRight,        // CGSSwap: Old desktop moves down, new from tr.
    CGSUp,                  // Old desktop moves up.
    CGSTopLeft,             // Old desktop moves tl.
    
    CGSTopRight,            // CGSSwap: old to tr. new from bl.
    CGSUpBottomRight,       // CGSSwap: old desktop up, new from br.
    CGSInBottom,            // CGSSwap: old in, new from bottom.
    CGSLeftBottomRight,     // CGSSwap: old one moves left, new from br.
    CGSRightBottomLeft,     // CGSSwap: old one moves right, new from bl.
    CGSInBottomRight,       // CGSSwap: onl one in, new from br.
    CGSInOut                // CGSSwap: old in, new out.
} CGSTransitionOption;

typedef struct _CGSTransitionSpec {
    uint32_t unknown1;
    CGSTransitionType type;
    CGSTransitionOption option;
    CGSWindow wid; /* Can be 0 for full-screen */
    float *backColour; /* Null for black otherwise pointer to 3 float array with RGB value */
} CGSTransitionSpec;


#define kCGSNullConnectionID ((CGSConnection)0)

#endif

typedef enum {
	CGNone = 0,
	CGFade,
	CGZoom,
	CGReveal,
	CGSlide,
	CGWarpFade,
	CGSwap,
	CGCube,
	CGWarpSwitch,
	CGFlip
} DDDAnimatedTabViewTransitionStyle;

@interface DDDAnimatedTabView : NSTabView {
	int             _transitionStyle;        // the style of transition to use; one of the DDDAnimatedTabViewTransitionStyle values enumerated above
	float			_transitionDuration;
}
- (float)transitionDuration;
- (void)setTransitionDuration:(float)newTransitionDuration;
- (DDDAnimatedTabViewTransitionStyle)transitionStyle;
- (void)setTransitionStyle:(DDDAnimatedTabViewTransitionStyle)newTransitionStyle;

- (void)turnWithTransition:(CGSTransitionType)transition option:(CGSTransitionOption)option duration:(float)duration;
- (IBAction)selectMatrix:(id)sender;
- (IBAction)selectEditor:(id)sender;
@end
