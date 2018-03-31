//
//  QCCProjectProcessor+Storage.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectProcessor.h"

@class QCCProjectGroup;

// Class provide builder QCCProjectGroup, QCCProjectFiles items from folder.
// Enumirate all files in folder
// Create QCCProjectEssences
// Return QCCProjectGroup with items as childe

@interface QCCProjectProcessor (Storage)

+ (nullable NSString *) storageFolder;

+ (nullable QCCProjectGroup *) sourceForPathString:(nonnull NSString *) path;
+ (nullable QCCProjectGroup *) sourceForPathString:(nonnull NSString *) path groupName:(nonnull NSString *) groupName;

@end
