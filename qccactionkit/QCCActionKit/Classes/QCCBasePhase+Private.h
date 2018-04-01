//
//  QCCBasePhase+Private.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <QCCActionKit/QCCActionKit.h>
@class QCCBaseAction;

@interface QCCBasePhase (Private) {
}


@property (nonatomic, strong) QCCBaseAction * action;
- (NSURL *) temeroryDirectoryURL;
// Interface for parent Action
- (QCCTaskManager *) taskManager;

@end
