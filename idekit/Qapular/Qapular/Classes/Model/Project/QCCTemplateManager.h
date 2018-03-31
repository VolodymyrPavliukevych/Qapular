//
//  QCCTemplateManager.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>

@class QCCBaseProjectDocument;


extern NSString  *const  QCCProjectSourceConfigurationKey;
/*
extern NSString  *const  QCCProjectSourceFileKey;
extern NSString  *const  QCCProjectSourceVirtualFileKey;
extern NSString  *const  QCCProjectSourceRootFileKey;
extern NSString  *const  QCCProjectSourceParentKey;
extern NSString  *const  QCCProjectSourcePathKey;
extern NSString  *const  QCCProjectSourceISAKey;
extern NSString  *const  QCCProjectSourceFileTypeKey;
extern NSString  *const  QCCProjectSourceContentKey;

extern NSString  *const  QCCProjectSourceGroupKey;
*/
extern NSString  *const  QCCProjectSourceDescriptionKey;
extern NSString  *const  QCCProjectSourceHeaderTypeKey;
extern NSString  *const  QCCProjectSourceIconKey;
extern NSString  *const  QCCProjectSourceTitleKey;

@interface QCCTemplateManager : NSObject

- (instancetype) initWithDocument:(QCCBaseProjectDocument *) document;
- (QCCProjectEssence  *) instanceProjectStructure:(NSDictionary *) sourceConfiguration isTemplate:(BOOL) template;

- (void) createInGroup:(QCCProjectGroup *) group newGrup:(void (^) (QCCProjectEssence *essence, NSError *error)) resultBlock;
- (void) createInGroup:(QCCProjectGroup *) group newFile:(void (^) (QCCProjectEssence *essence, NSError *error)) resultBlock;

- (NSArray *) essenceWithURLs:(NSArray *) URLs importedInGroup:(QCCProjectGroup *) rootGroup;

@end
