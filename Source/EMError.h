//
//  EMError.h
//  Error Manager App
//
//  Created by Raphael Bost on 28/10/06.
//  Copyright 2006 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*!
	@class
	@abstract   Model class to encapsulate errors (like NSNotification)
	@discussion EMError is not mutable.
				The priority field is not used in EMErrorManager since it doesn't manage multiple folowing errors.
*/


@interface EMError : NSObject {
	NSString	*_name;
	NSString	*_description;
	short int	_priority;
}
/*!
	@method     
	@abstract   Returns an error with given name and description and whose priority is 0
	@discussion Returns an error with normal priority
	@param		name Error's name
	@param		description Error's description
 */
+ (EMError *)errorWithName:(NSString *)name description:(NSString *)description;

/*!
    @method     
	@abstract   Returns an error with given name, description and priority
	@discussion Priority 0 is normal, less than 0 is lower and more is greater
	@param		name Error's name
	@param		description Error's description
	@param		p Error's priority
*/

+ (EMError *)errorWithName:(NSString *)name description:(NSString *)description priority:(short int)p;

/*!
    @method     
	@abstract	Initializes the receiver, a newly allocated EMError object
	@discussion Priority 0 is normal, less than 0 is lower and more is greater
	@param		name Error's name
	@param		description Error's description
	@param		p Error's priority
*/

- (id)initWithName:(NSString *)name description:(NSString *)description priority:(short int)p;

/*!
    @method     
	@abstract   Returns the receiver's name
*/
- (NSString *)name;

/*!
    @method     
	@abstract   Returns the receiver's description
*/

- (NSString *)description;
@end
