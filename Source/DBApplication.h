#import <Cocoa/Cocoa.h>

@interface DBApplication: NSApplication
{
    IBOutlet NSMenuItem *zoomToFullScreenMenuItem;
    // a set of "standard" images used to fill in filter CIImage parameters
    // see the EffectStackController setAutomaticDefaults: method
    CIImage *texture;               // a texture - used for CIGlassDistortion
    CIImage *shadingemap;           // a material map used for shading - used for CIShadedMaterial
    CIImage *alphaemap;             // a material map with alpha that's not all 1 - used for CIRippleTransition
    CIImage *ramp;                  // color ramp - a width "n" height 1 image - used for CIColorMap
    CIImage *mask;                  // mask (grayscale image) used for CIDisintegrateWithMaskTransition
    // original paths for the above images
    NSString *texturepath;
    NSString *shadingemappath;
    NSString *alphaemappath;
    NSString *ramppath;
    NSString *maskpath;
}

- (void)setFullScreenMenuTitle:(BOOL)inFullScreen;

// accessors for default images for filters
- (CIImage *)defaultTexture;
- (NSString *)defaultTexturePath;
- (CIImage *)defaultShadingEMap;
- (NSString *)defaultShadingEMapPath;
- (CIImage *)defaultAlphaEMap;
- (NSString *)defaultAlphaEMapPath;
- (CIImage *)defaultRamp;
- (NSString *)defaultRampPath;
- (CIImage *)defaultMask;
- (NSString *)defaultMaskPath;

@end
