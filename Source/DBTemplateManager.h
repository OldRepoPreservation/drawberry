//
//  DBTemplateManager.h
//  DrawBerry
//
//  Created by Raphael Bost on 28/04/09.
//  Copyright 2009 Raphael Bost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *DBTemplateMenuDidChangeNotification;

@interface DBTemplateManager : NSObject {
	NSArray *_builtInTemplates;
	NSMutableArray *_customTemplates;
	
	NSMenu *_templatesMenu;
}
+ (id)sharedTemplateManager;


- (void)loadBuiltInTemplates;
- (void)loadCustomTemplates;
- (void)writeCustomTemplates;
- (NSMutableArray *)customTemplates;
- (void)setCustomTemplate:(NSArray *)templates;
- (NSDictionary *)templateForTag:(int)tag;
- (NSSize)sizeForTemplateTag:(int)tag;
- (NSDictionary *)customTemplateForTag:(int)tag;
- (NSDictionary *)builtInTemplateForTag:(int)tag;
- (void)addUntitledTemplate;
- (void)addCustomTemplateWithName:(NSString *)name size:(NSSize)size;
- (void)removeCustomTemplateWithTag:(int)tag;

- (void)setName:(NSString *)name forCustomTemplateAtTag:(int)tag;
- (void)setSize:(NSSize)size forCustomTemplateAtTag:(int)tag;
- (void)setWidth:(float)width forCustomTemplateAtTag:(int)tag;
- (void)setHeight:(float)height forCustomTemplateAtTag:(int)tag;


- (void)updateTemplatesMenu;
- (NSMenu *)templatesMenu;
@end
