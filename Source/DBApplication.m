#import "DBApplication.h"

// this is a subclass of NSApplication

@implementation DBApplication

- (void)awakeFromNib
{
    // fetch textures now
    // provide a set of "standard" images used to fill in filter CIImage parameters
    // see the EffectStackController setAutomaticDefaults: method
    // a texture - used for CIGlassDistortion
    texturepath = [[[NSBundle mainBundle] pathForResource:@"smoothtexture" ofType: @"tiff"] retain];
    // a material map used for shading - used for CIShadedMaterial
    shadingemappath = [[[NSBundle mainBundle] pathForResource:@"lightball" ofType: @"tiff"] retain];
    // a material map with alpha that's not all 1 - used for CIRippleTransition
    alphaemappath = [[[NSBundle mainBundle] pathForResource:@"restrictedshine" ofType: @"tiff"] retain];
    // color ramp - a width "n" height 1 image - used for CIColorMap
    ramppath = [[[NSBundle mainBundle] pathForResource:@"colormap" ofType: @"tiff"] retain];
    // mask (grayscale image) used for CIDisintegrateWithMaskTransition
    maskpath = [[[NSBundle mainBundle] pathForResource:@"mask" ofType: @"tiff"] retain];
	
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}

- (void)dealloc
{
    [texturepath release];
    [texture release];
    [shadingemappath release];
    [shadingemap release];
    [alphaemappath release];
    [alphaemap release];
    [ramppath release];
    [ramp release];
    [maskpath release];
    [mask release];
    [super dealloc];
}

// method used to set the title of the "full screen" menu item
// (depends on the current state)
- (void)setFullScreenMenuTitle:(BOOL)inFullScreen
{
    if (inFullScreen)
        [zoomToFullScreenMenuItem setTitle:@"Exit Full Screen"];
    else
        [zoomToFullScreenMenuItem setTitle:@"Zoom To Full Screen"];
}

// accessors for default images (and their paths) for filters
// load the images only on demand to keep launch time down
- (CIImage *)defaultTexture
{
    if(texture == NULL)
	texture = [[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:texturepath]] retain];
    return texture;
}

- (NSString *)defaultTexturePath
{
    return texturepath;
}

- (CIImage *)defaultShadingEMap
{
    if(shadingemap == NULL)
	shadingemap = [[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:shadingemappath]] retain];
    return shadingemap;
}

- (NSString *)defaultShadingEMapPath
{
    return shadingemappath;
}

- (CIImage *)defaultAlphaEMap
{
    if(alphaemap == NULL)
	alphaemap = [[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:alphaemappath]] retain];
    return alphaemap;
}

- (NSString *)defaultAlphaEMapPath
{
    return alphaemappath;
}

- (CIImage *)defaultRamp
{
    if(ramp == NULL)
	ramp = [[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:ramppath]] retain];
    return ramp;
}

- (NSString *)defaultRampPath
{
    return ramppath;
}

- (CIImage *)defaultMask
{
    if(mask == NULL)
	mask = [[CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:maskpath]] retain];
    return mask;
}

- (NSString *)defaultMaskPath
{
    return maskpath;
}

@end
