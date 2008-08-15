//
//  ErrorManager.h
//  Error Manager App
//
//  Created by Raphael Bost on 28/10/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EMErrorView.h"

@class EMError;

/*!
    @class
    @abstract    Controller class of EMError objects. Works like an NSNotificationCenter : post errors and it will display them.
*/

@interface EMErrorManager : NSObject {
	EMErrorView	*_errorView;
	NSTimer *_timer;
	NSPoint _offsetPoint;
}
/*!
    @method     
    @abstract   Initializes the receiver, a newly allocated EMErrorManager object, attaching the error view and replacing it in the designated corner.
    @discussion This will automatically creates a new EMErrorView corresponding to the error manager
	@param		view		The view on which the error view will be displayed
	@param		c			The corner where the error view will be displayed on the attached view
	@param		offset		The translation vector relative to the corner
*/

- (id) initWithAttachedView:(NSView *)view corner:(EMCorner)c offset:(NSPoint)offset;

/*!
    @method     
    @abstract   Attach the error view to another view
	@param		v	The new attached view
*/
- (void)attachViewToNewView:(NSView *)v;

/*!
    @method     
    @abstract   Remove the error view of the attached view
    @discussion Errors won't be displayed anymore
*/
- (void)removeErrorView;

/*!
    @method     
    @abstract   Post the error to the manager which will display it on the error view
	@param		error	The error which will be displayed

*/

- (void)postError:(EMError *)error;

/*!
    @method     
	@abstract   Post a new error with given name and description to the manager which will display it on the error view
	@param		name	The name of the error which will be displayed
	@param		description	The description of the error which will be displayed
 */

- (void)postErrorName:(NSString *)name description:(NSString *)description;

/*!
    @method     
    @abstract   Returns the error view of the manager
*/
- (EMErrorView *)errorView;

/*!
    @method     
    @abstract   Returns the offset point relative to the corner
*/
- (NSPoint)offsetPoint;

/*!
    @method     
    @abstract   Set the receiver's offset point relative to the corner
*/
- (void)setOffsetPoint:(NSPoint)newOffsetPoint;
@end
