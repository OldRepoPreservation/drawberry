//
//  EMErrorView.h
//  Error Manager App
//
//  Created by Raphael Bost on 28/10/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
    @header EMErrorView
    @abstract   This header contains all what is needed to configure and use the error view
*/


/*!
    @typedef 
    @abstract   The four different corners of the view
	@constant   UpperLeftCorner	The upper left corner of the view
	@constant   UpperRightCorner	The upper right corner of the view
	@constant   LowerLeftCorner	The lower left corner of the view
	@constant   LowerRightCorner	The lower right corner of the view
*/
typedef enum {
	UpperLeftCorner = 0,
	UpperRightCorner = 1,
	LowerLeftCorner = 2,
	LowerRightCorner = 3
} EMCorner;

@class EMError;

/*!
    @class
    @abstract    The error view class.
    @discussion  This class will display properly the EMError messages which have been transmitted by the EMErrorManager
*/

@interface EMErrorView : NSView {
	
	NSView				*_attachedView;
	EMCorner			_baseCorner;
	
	EMError				*_currentError;
	
	NSDictionary		*_titleAttributes;
	NSDictionary		*_descriptionAttributes;
	
	float				_topMargin;
	float				_verticalMargin;
	
	NSImage				*_closeImage;
	NSImage				*_closeImagePressed;
	NSRect				_imageRect;
	
	BOOL				_mouseOver;
	BOOL				_closePressed;
	NSTrackingRectTag	_rolloverTrackingRectTag;
	
	NSTimeInterval		_timeout;
	
	NSColor				*_backgroundColor;
	NSPoint				_offsetPoint;
	@protected
		NSTimer				*_timeoutTimer;
}

/*!
    @method     
    @abstract   Initializes the receiver, a newly allocated EMErrorManager object.
    @discussion The error view will be attached to the view : the error manager will make it a subview of v
	@param		v		The view on which the error view will be displayed
	@param		corner	The corner where the error view will be displayed on the attached view

*/
- (id)initWithView:(NSView *)v baseCorner:(EMCorner)baseCorner;

/*!
    @method     
    @abstract   Shows error in the error view
    @discussion The error must have a name or a description to be displayed
	@param		e The displayed error

*/
- (void)displayError:(EMError *)e;

/*!
    @method     
    @abstract   Returns the attributes that will be used to draw error's name (error view title)
    @discussion The returns is an NSDictionary that contains the same keys as the dictionary used for NSAttributedString
*/

- (NSDictionary *)titleAttributes;

/*!
    @method     
    @abstract   Set the receiver's title attributes used to draw the error's name
	@discussion The dictionary must be formated like NSAttributedString dictionary attributes dictionary
*/

- (void)setTitleAttributes:(NSDictionary *)d;

/*!
    @method     
	@abstract   Returns the attributes that will be used to draw error's description 
	@discussion The returns is an NSDictionary that contains the same keys as the dictionary used for NSAttributedString
*/
- (NSDictionary *)descriptionAttributes;

/*!
    @method     
	@abstract   Set the receiver's description attributes used to draw the error's description
	@discussion The dictionary must be formated like NSAttributedString dictionary attributes dictionary
*/
- (void)setDescriptionAttributes:(NSDictionary *)d;

/*!
    @method     
    @abstract   Returns the receiver's base corner used to draw the error view
*/
- (EMCorner)baseCorner;

/*!
    @method     
    @abstract   Set the receiver's base corner
*/
- (void)setBaseCorner:(EMCorner)corner;

/*!
    @method     
    @abstract   Returns the receiver's background color
*/
- (NSColor *)backgroundColor ;

/*!
    @method     
    @abstract   Set the receiver's background color
    @discussion By default the background color is [NSColor clearColor];
*/
- (void)setBackgroundColor:(NSColor *)color;

/*!
    @method     
    @abstract   Returns the time after which the receiver will disappear
    @discussion The NSTimeInterval is in seconds
*/
- (NSTimeInterval)timeout ;

/*!
    @method     
    @abstract   Set the time after which the receiver will disappear
    @discussion The NSTimeInterval is in seconds
				By default, the timeout is set to four seconds
*/
- (void)setTimeout:(NSTimeInterval)t;

/*!
    @method     
    @abstract   Returns the receiver's close button image
    @discussion By default this image is not nil
*/
- (NSImage *)closeImage;

/*!
    @method     
    @abstract   Set the receiver's close button image
*/
- (void)setCloseImage:(NSImage *)image;

/*!
    @method     
    @abstract   Returns the receiver's alternate close button image
    @discussion By default this image is not nil
*/
- (NSImage *)closeImagePressed ;

/*!
    @method     
    @abstract   Set the receiver's alternate close button image
*/
- (void)setCloseImagePressed:(NSImage *)image;

/*!
    @method     
    @abstract   Returns the view on which the receiver is displayed
*/
- (NSView *)attachedView ;

/*!
    @method     
    @abstract   Set the view on which the receiver is dispplayed
    @discussion Better use the attachViewToNewView: method in EMErrorManager
				If you change this without changing the receiver's superview, it will make bad computation for receiver's frame
*/
- (void)setAttachedView:(NSView *)view;

@end
