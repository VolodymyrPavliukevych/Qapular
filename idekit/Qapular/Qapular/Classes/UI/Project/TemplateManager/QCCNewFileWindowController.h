//
//  QCCNewFileWindowController.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class QCCProjectGroup;
@class QCCProjectEssence;
@class QCCProjectFile;
@interface QCCNewFileWindowController : NSWindowController

- (instancetype) initWithParentFolder:(QCCProjectGroup *)group
                            templates:(NSArray *) templates
                           completion:(void (^) (id object)) resultBlock;


@end
