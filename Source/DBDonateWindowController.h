//
//  DBDonateWindowController.h
//  DrawBerry
//
//  Created by Raphael Bost on 26/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBDonateWindowController : NSWindowController {

}
- (void)showDonateWindowIfNecessary;
- (IBAction)donate:(id)sender;
- (IBAction)alreadyDonated:(id)sender;
@end
