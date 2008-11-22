//
//  DBFilterStack.m
//  DrawBerry
//
//  Created by Raphael Bost on 24/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DBFilterStack.h"

#import "EffectStack.h"
#import "FilterView.h"
#import "DBApplication.h"
#import "DBLayer.h"
#import "DBCIFilterPickerController.h"

NSString *DBFilterStackDidChangeNotification = @"Filter Stack Did Change";

@implementation DBFilterStack

- (id)init
{
	self = [super init];
	            
	_filterBoxes = [[NSMutableArray alloc] initWithCapacity:5]; // no more than 5 filters
	_effects = [[EffectStack alloc] init];
	
	return self;
}
 
- (void)dealloc
{
	[_effects release];
	[_filterBoxes release];
	
	[super dealloc];
}  

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	
	[_effects release];
	_effects = [[decoder decodeObjectForKey:@"Effects"] retain];
	[self updateBoxes];
	[self updateFilterPoints];
	
	return self;
}   

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_effects forKey:@"Effects"];
}

- (void)updateBoxes
{
	[_filterBoxes release];
	_filterBoxes = [[NSMutableArray alloc] initWithCapacity:5];
	
	int i;

	for( i = 0; i < [_effects layerCount]; i++ )
	{
    	[_filterBoxes addObject:[self createUIForFilter:[_effects filterAtIndex:i] index:i]];
	}
}

- (NSArray *)boxes
{
	return _filterBoxes;
}

- (EffectStack *)effects
{
	return _effects;
}                   

- (DBLayer *)layer
{
	return _layer;
}

- (void)setLayer:(DBLayer *)newLayer
{
	_layer = newLayer;
}
 
- (void)setChanges
{
	[[NSNotificationCenter defaultCenter] postNotificationName:DBFilterStackDidChangeNotification object:self];
	
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
} 

- (void)filterChange
{
//	[_layer updateRenderInView:nil];
//	[[[_layer layerController] drawingView] setNeedsDisplay:YES];	
}
// this is the glue code you call to insert a filter layer into the effect stack. this handles save for undo, etc.
- (void)insertFilter:(CIFilter *)f atIndex:(NSNumber *)index
{
    // actually insert the filter layer into the effect stack
    [_effects insertFilterLayer:f atIndex:[index intValue]];
    // set filter attributes to their defaults
    [[_effects filterAtIndex:[index intValue]] setDefaults];
    // set any automatic defaults we need (generally the odd image parameter)
    [self setAutomaticDefaults:[_effects filterAtIndex:[index intValue]] atIndex:[index intValue]];
	[[NSNotificationCenter defaultCenter] postNotificationName:DBFilterStackDidChangeNotification object:self];
    // do "save for undo"
//    [[[[self doc] undoManager] prepareWithInvocationTarget:self] removeFilterImageOrTextAtIndex:index];
//    [[[self doc] undoManager] setActionName:[NSString stringWithFormat:@"Filter %@", [CIFilter localizedNameForFilterName:NSStringFromClass([f class])], nil]];
    // dirty the documdent
    [self setChanges];
	[self updateFilterPoints];
    // finally, let core image render the view
//    [_inspectingCoreImageView setNeedsDisplay:YES];
}

// this is the high-level glue code you call to remove a layer (of any kind) from the effect stack. this handles save for undo, etc.
- (void)removeFilterAtIndex:(NSNumber *)index
{
    CIFilter *filter;
    
    // first get handles to parameters we want to retain for "save for undo"

	filter = [[_effects filterAtIndex:[index intValue]] retain];

    // actually remove the layer from the effect stack here
    [_effects removeLayerAtIndex:[index intValue]];
	[[NSNotificationCenter defaultCenter] postNotificationName:DBFilterStackDidChangeNotification object:self];
    // do "save for undo"

//        [[[[self doc] undoManager] prepareWithInvocationTarget:self] insertFilter:filter atIndex:index];
//        [[[self doc] undoManager] setActionName:[NSString stringWithFormat:@"Filter %@", [CIFilter localizedNameForFilterName:NSStringFromClass([filter class])], nil]];
//        [filter release];
    // dirty the document
    [self setChanges];
	[self updateFilterPoints];

    // finally, let core image render the view
//    [_inspectingCoreImageView setNeedsDisplay:YES];
}

// this handles a change to each layer's "enable" check box
- (IBAction)enableCheckBoxAction:(id)sender
{
//    [_effects setLayer:[sender tag] enabled:([sender state] == NSOnState)?YES:NO];
    [_effects setLayer:[_filterBoxes indexOfObject:[sender superview]] enabled:([sender state] == NSOnState)?YES:NO];
    [self setChanges];
//    [_inspectingCoreImageView setNeedsDisplay:YES];
}

// a layer's plus button inserts another new layer after this one
- (IBAction)plusButtonAction:(id)sender
{
    NSDictionary *d;
	FilterView *fv;
    int index;
    
	// get the filter
    d = [[DBCIFilterPickerController sharedCIFilterPickerController] collectFilterImageOrText];

    if (d == nil)
        return;

	index = [_filterBoxes indexOfObject:[sender superview]] +1;
	
    [self insertFilter:[d valueForKey:@"filter"] atIndex:[NSNumber numberWithInt:index]];
	
	fv = [self createUIForFilter:[d valueForKey:@"filter"] index:index];                 
	[_filterBoxes insertObject:fv atIndex:index];
	[fv release];
	
	[self setChanges];
}

- (void)addFilter:(id)sender
{
    NSDictionary *d;
	FilterView *fv;
	CIFilter *filter;
    int index;
    
	// get the filter
    d = [[DBCIFilterPickerController sharedCIFilterPickerController] collectFilterImageOrText];
    
	if([sender isKindOfClass:[CIFilter class]]){
		filter = sender;	
	}else{
	    if (d == nil)
	        return;

		filter = [d valueForKey:@"filter"];
	}
	
	index = [_filterBoxes count];
	
    [self insertFilter:filter atIndex:[NSNumber numberWithInt:index]];
	
	fv = [self createUIForFilter:[d valueForKey:@"filter"] index:index];                 
	[_filterBoxes insertObject:fv atIndex:index];
	[fv release];
	
	[self setChanges];	
}

// for a new filter, set up the odd image parameter
- (void)setAutomaticDefaults:(CIFilter *)f atIndex:(int)index
{
    if ([NSStringFromClass([f class]) isEqualToString:@"CIGlassDistortion"])
    {
        // glass distortion gets a default texture file
        [f setValue:[NSApp defaultTexture] forKey:@"inputTexture"];
        [_effects setFilterLayer:index imageFilePathValue:[NSApp defaultTexturePath] forKey:@"inputTexture"];
    }
    else if ([NSStringFromClass([f class]) isEqualToString:@"CIRippleTransition"])
    {
        // ripple gets a material map for shading the ripple that has a transparent alpha except specifically for the shines and darkenings
        [f setValue:[NSApp defaultAlphaEMap] forKey:@"inputShadingImage"];
        [_effects setFilterLayer:index imageFilePathValue:[NSApp defaultAlphaEMapPath] forKey:@"inputShadingImage"];
    }
    else if ([NSStringFromClass([f class]) isEqualToString:@"CIPageCurlTransition"])
    {
        // we set up a good page curl default material map (like that for the ripple transition)
        [f setValue:[NSApp defaultAlphaEMap] forKey:@"inputShadingImage"];
        [_effects setFilterLayer:index imageFilePathValue:[NSApp defaultAlphaEMapPath] forKey:@"inputShadingImage"];
        // the angle chosen shows off the alpha material map's shine on the leading curl
        [f setValue:[NSNumber numberWithFloat:-M_PI*0.25] forKey:@"inputAngle"];
    }
    else if ([NSStringFromClass([f class]) isEqualToString:@"CIShadedMaterial"])
    {
        // shaded material gets an opaque material map that shows off surfaces well
        [f setValue:[NSApp defaultShadingEMap] forKey:@"inputShadingImage"];
        [_effects setFilterLayer:index imageFilePathValue:[NSApp defaultShadingEMapPath] forKey:@"inputShadingImage"];
    }
    else if ([NSStringFromClass([f class]) isEqualToString:@"CIColorMap"])
    {
        // color map gets a gradient image that's a color spectrum
        [f setValue:[NSApp defaultRamp] forKey:@"inputGradientImage"];
        [_effects setFilterLayer:index imageFilePathValue:[NSApp defaultRampPath] forKey:@"inputGradientImage"];
    }
    else if ([NSStringFromClass([f class]) isEqualToString:@"CIDisintegrateWithMaskTransition"])
    {
        // disintegrate with mask transition gets a mask that has a growing star
        [f setValue:[NSApp defaultMask] forKey:@"inputMaskImage"];
        [_effects setFilterLayer:index imageFilePathValue:[NSApp defaultMaskPath] forKey:@"inputMaskImage"];
    }
    else if ([NSStringFromClass([f class]) isEqualToString:@"CICircularWrap"])
    {
        // circular wrap needs to be aware of the size of the screen to put its data in the right place
		NSView *displayView = nil;
		
		NSRect bounds = [displayView bounds];
        float cx = bounds.origin.x + 0.5 * bounds.size.width;
        float cy = bounds.origin.y + 0.5 * bounds.size.height;
        [f setValue:[CIVector vectorWithX:cx Y:cy] forKey:@"inputCenter"];
    }
}

// a layer's mins button removes the layer
- (IBAction)minusButtonAction:(id)sender
{
 	int index = [_filterBoxes indexOfObject:[sender superview]];
	[_filterBoxes removeObjectAtIndex:index];
    [self removeFilterAtIndex:[NSNumber numberWithInt:index]];
}

// the reset button removes all layers from the effect stack
- (IBAction)resetButtonAction:(id)sender
{
    int i, count;
    
	[_filterBoxes removeAllObjects];
	
    // kill off all layers from the effect stack
    count = [_effects layerCount];
    if (count == 0)
        return;

    for (i = count - 1; i > 0; i--) // note: spare the image at the start
            [self removeFilterAtIndex:[NSNumber numberWithInt:i]];
   
    // dirty the document
    [self setChanges];
    // let core image recompute the view
//    [_inspectingCoreImageView setNeedsDisplay:YES];
}

// automatically generate the UI for an effect stack filter layer
// returning an NSBox (actually FilterView is a subclass of NSBox)
- (FilterView *)createUIForFilter:(CIFilter *)f index:(int)index
{
    BOOL hasBackground;
    NSDictionary *attr;
    NSArray *inputKeys;
    NSString *key, *typestring, *classstring;
    NSEnumerator *enumerator;
    NSRect frame;
    FilterView *fv;
    NSView *view = nil;
	NSView *displayView = nil;
	
    
    // create box first
//    view = [[self window] contentView];
    frame = [view bounds];
    frame.size.width -= 12;
    frame.origin.x += 6;
//    frame.size.height -= inspectorTopY;
	frame = NSMakeRect(0,0,300,100);
	
    fv = [[FilterView alloc] initWithFrame:frame];
    [fv setFilter:f];
    [fv setHidden:NO];
//    [[[self window] contentView] addSubview:fv];
//    [fv setTitlePosition:NSNoTitle];
//    [fv setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
//    [fv setBorderType:NSNoBorder];
//    [fv setBoxType:NSBoxPrimary];
    [fv setMaster:self];
    [fv setTag:index];
    // first compute size of box with all the controls
    [fv tryFilterHeader:f];
    attr = [f attributes];
    inputKeys = [f inputKeys];
    // decide if this filter has a background image parameter (true for blend modes and Porter-Duff modes)
    hasBackground = NO;
    enumerator = [inputKeys objectEnumerator];
    while ((key = [enumerator nextObject]) != nil) 
    {
        id parameter = [attr objectForKey:key];
        if ([parameter isKindOfClass:[NSDictionary class]])
        {
            classstring = [(NSDictionary *)parameter objectForKey: kCIAttributeClass];
            if ([classstring isEqualToString:@"CIImage"] && [key isEqualToString:@"inputBackgroundImage"])
                hasBackground = YES;
        }
    }
    // enumerate all input parameters and reserve space for their generated UI
    enumerator = [inputKeys objectEnumerator];
    while ((key = [enumerator nextObject]) != nil) 
    {
        id parameter = [attr objectForKey:key];
        if ([parameter isKindOfClass:[NSDictionary class]])
        {
            classstring = [(NSDictionary *)parameter objectForKey:kCIAttributeClass];
            if ([classstring isEqualToString:@"NSNumber"])
            {
                typestring = [(NSDictionary *)parameter objectForKey:kCIAttributeType];
                if ([typestring isEqualToString:kCIAttributeTypeBoolean])
                    // if it's a boolean type, save space for a check box
                    [fv tryCheckBoxForFilter:f key:key displayView:displayView];
                else
                    // otherwise space space for a slider
                    [fv trySliderForFilter:f key:key displayView:displayView];
            }
            else if ([classstring isEqualToString:@"CIColor"])
                // save space for a color well
                [fv tryColorWellForFilter:f key:key displayView:displayView];
            else if ([classstring isEqualToString:@"CIImage"])
            {
                // don't bother to create a UI element for the chained image
                if (hasBackground)
                {
                    // the chained image is the background image for blend modes and Porter-Duff modes
                    // it is provided by what's above this layer in the effect stack
                    if (![key isEqualToString:@"inputBackgroundImage"])
                        // save space for an image well
                        [fv tryImageWellForFilter:f key:key displayView:displayView];
                }
                else
                {
                    // the chained image is the input image for all other filters
                    // it is provided by what's above this layer in the effect stack
                    if (![key isEqualToString:@"inputImage"])
                        // save space for an image well
                        [fv tryImageWellForFilter:f key:key displayView:displayView];
                }
            }
            else if ([classstring isEqualToString:@"NSAffineTransform"])
                // save space for transform inspection widgets
                [fv tryTransformForFilter:f key:key displayView:displayView];
            else if ([classstring isEqualToString:@"CIVector"])
            {
                // check for a vector with no attributes
                typestring = [(NSDictionary *)parameter objectForKey:kCIAttributeType];
                if (typestring == nil)
                    // save space for a 4-element vector inspection widget (4 text fields)
                    [fv tryVectorForFilter:f key:key displayView:displayView];
                else if ([typestring isEqualToString:kCIAttributeTypeOffset])
                    [fv tryOffsetForFilter:f key:key displayView:displayView];
                // note: the other CIVector parameters are handled in mouse down processing of the core image view
            } 
        }
    }
    // now resize the box to hold the controls we're about to make
    [fv trimBox];
    // now add all the controls
    [fv addFilterHeader:f tag:index enabled:[_effects layerEnabled:index]];
    attr = [f attributes];
    inputKeys = [f inputKeys];
    // enumerate all input parameters and generate their UI
    enumerator = [inputKeys objectEnumerator];
    while ((key = [enumerator nextObject]) != nil) 
    {
        id parameter = [attr objectForKey:key];
        if ([parameter isKindOfClass:[NSDictionary class]])
        {
            classstring = [(NSDictionary *)parameter objectForKey: kCIAttributeClass];
            if ([classstring isEqualToString:@"NSNumber"])
            {
                typestring = [(NSDictionary *)parameter objectForKey: kCIAttributeType];
                if ([typestring isEqualToString:kCIAttributeTypeBoolean])
                    // if it's a boolean type, generate a check box
                    [fv addCheckBoxForFilter:f key:key displayView:displayView];
                else
                    // otherwise generate a slider
                    [fv addSliderForFilter:f key:key displayView:displayView];
            }
            else if ([classstring isEqualToString:@"CIImage"])
            {
                if (hasBackground)
                {
                    // the chained image is the background image for blend modes and Porter-Duff modes
                    // it is provided by what's above this layer in the effect stack
                    if (![key isEqualToString:@"inputBackgroundImage"])
                        // generate an image well
                        [fv addImageWellForFilter:f key:key displayView:displayView];
                }
                else
                {
                    // the chained image is the input image for all other filters
                    // it is provided by what's above this layer in the effect stack
                    if (![key isEqualToString:@"inputImage"])
                        // generate an image well
                        [fv addImageWellForFilter:f key:key displayView:displayView];
                }
            }
            else if ([classstring isEqualToString:@"CIColor"])
                // generate a color well
                [fv addColorWellForFilter:f key:key displayView:displayView];
            else if ([classstring isEqualToString:@"NSAffineTransform"])
                // generate transform inspection widgets
                [fv addTransformForFilter:f key:key displayView:displayView];
            else if ([classstring isEqualToString:@"CIVector"])
            {
                // check for a vector with no attributes
                typestring = [(NSDictionary *)parameter objectForKey:kCIAttributeType];
                if (typestring == nil)
                    // generate a 4-element vector inspection widget (4 text fields)
                    [fv addVectorForFilter:f key:key displayView:displayView];
                else if ([typestring isEqualToString:kCIAttributeTypeOffset])
                    [fv addOffsetForFilter:f key:key displayView:displayView];
                // the rest are handled in mouse down processing
            } 
        }
    }
    // retrun the box with the filter's UI
    return fv;
}

// glue code for determining if a filter layer has a missing image (and should be drawn red to indicate as such)
- (BOOL)effectStackFilterHasMissingImage:(CIFilter *)f
{
    return [_effects filterHasMissingImage:f];
}

- (void)registerFilterLayer:(CIFilter *)filter key:(NSString *)key imageFilePath:(NSString *)path
{
    int i, count;
    
    count = [_effects layerCount];
    for (i = 0; i < count; i++)
    {
        if (filter == [_effects filterAtIndex:i])
        {
            [_effects setFilterLayer:i imageFilePathValue:path forKey:key];
            break;
        }
    }
}

- (NSString *)imageFilePathForFilterLayer:(CIFilter *)filter key:(NSString *)key
{
    int i, count;
    
    count = [_effects layerCount];
    for (i = 0; i < count; i++)
    {
        if (filter == [_effects filterAtIndex:i])
            return [_effects filterLayer:i imageFilePathValueForKey:key];
    }
    return nil;
}

- (void)setFilter:(CIFilter *)f value:(id)val forKey:(NSString *)key
{
//    FunHouseDocument *d;
    id oldValue;
          
//  //  d = (FunHouseDocument *)[controller document];
    oldValue = [[f valueForKey:key] retain];
    [f setValue:val forKey:key];
    // this is the special way the undo manager saves old object values so it can undo properly
//    [[[d undoManager] prepareWithInvocationTarget:self] setFilter:f value:oldValue forKey:key];
    [oldValue release];
//    NSLog(@"setfilter:value:");
	// redisplay layer 
	[_layer updateRenderInView:nil];
	[[[_layer layerController] drawingView] setNeedsDisplay:YES];
	
}

- (CIImage *)applyFiltersToImage:(CIImage *)inputImage
{
    return [_effects coreImageResultForRect:NSZeroRect inputImage:inputImage];
}

- (void)updateFilterPoints
{
//	free(_filterPoints);
	_filterPointsCount = 0;
	
	int i, count;
    CIFilter *f;
    NSEnumerator *e;
    NSDictionary *attr, *parameter;
    NSString *key, *classstring;
    NSArray *inputKeys;
    EffectStack *es;
    NSString *str, *localizedParameter;
	CIFilterPoint ciPoint;
    
    // enumerate filters, images, text placements in the effect stack (bottom-to-top)
    es = _effects;
    count = [es layerCount];
    for (i = 0; i < count; i++)
    {
        // if the layer isn't enabled, don't show the handle either
        if (![es layerEnabled:i])
            continue;

         // filter effect stack element
          	f = [es filterAtIndex:i];
          	if (f == nil)
            	return;
          	attr = [f attributes];
          	// iterate over parameters, look for parameters containing an origin to be displayed
          	inputKeys = [f inputKeys];
          	e = [inputKeys objectEnumerator];
          	while ((key = [e nextObject]) != nil) 
          	{
          		parameter = [attr objectForKey:key];
           		classstring = [parameter objectForKey:kCIAttributeClass];
             	localizedParameter = [parameter objectForKey:kCIAttributeDisplayName];
              	str = [NSString stringWithFormat:@"%@ %@", [CIFilter localizedNameForFilterName:NSStringFromClass([f class])], localizedParameter, nil];
		        
				if([classstring isEqualToString:@"CIVector"] || [classstring isEqualToString:@"NSAffineTransform"]){
			 		ciPoint = CIFilterPointWithCIFilter(f,key);
					_filterPointsCount++;
					_filterPoints = realloc(_filterPoints,_filterPointsCount*sizeof(CIFilterPoint));
					_filterPoints[_filterPointsCount-1] = ciPoint;					
				}
          }
    }    
}

- (int)filterPointsCount
{
	return _filterPointsCount;
}                             

- (CIFilterPoint *)filterPoints
{
	return _filterPoints;
}

- (CIFilterPoint)filterPointUnderPoint:(NSPoint)p
{
	int i;
	CIFilterPoint ciPoint;

	for( i = 0; i < _filterPointsCount; i++ )
	{
		ciPoint = _filterPoints[i];
		
		if(DBPointIsOnKnobAtPoint(p,DBPointForCIFilterPoint(ciPoint))){
			return ciPoint;
		}
	}
	
	return CIZeroFilterPoint;
}
@end
