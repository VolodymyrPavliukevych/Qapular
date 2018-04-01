//
//  QCCBasePhase+Private.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCBasePhase+Private.h"
#import "QCCBasePhase.h"

@implementation QCCBasePhase (Private)

@dynamic action;

- (NSURL *) temeroryDirectoryURL {
    if ([_action.dataSource conformsToProtocol:@protocol(QCCBaseActionDataSource)] && [_action.dataSource respondsToSelector:@selector(temeroryDirectoryURL)])
        return [_action.dataSource temeroryDirectoryURL];
    else
        return nil;
}

- (QCCTaskManager *) taskManager {
    return _taskManager;
}

@end
