//
//  QCCNewFolderWindowController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QCCProjectGroup;
@class QCCProjectEssence;
@class QCCProjectFile;

@interface QCCNewFolderWindowController : NSWindowController

- (instancetype) initWithFolder:(QCCProjectGroup *) group completion:(void (^) (QCCProjectEssence *group)) resultBlock;

@end
