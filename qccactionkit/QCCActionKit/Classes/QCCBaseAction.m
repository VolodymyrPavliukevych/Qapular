//
//  QCCBaseAction.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCBaseAction.h"
#import "QCCBasePhase.h"
#import "QCCBaseAction+Private.h"

@implementation QCCBaseAction

static int64_t BaseActionProgressTotalUnitCount =    100;

- (instancetype) init {
    self = [super init];
    
    if (self) {
        
        _phasesArray = [[self class] phasesQueue];
        _progress = [NSProgress  progressWithTotalUnitCount:BaseActionProgressTotalUnitCount];
        _progress.cancellable = YES;
        _progress.pausable = NO;
        
        _startedPhasesArray = [NSMutableArray new];
    }
    
    return self;
}

- (BOOL)start {
    Class nextPhase = [self nextPhase];
    if (nextPhase)
        return YES;
    else
        return NO;
}

-(BOOL)cancel {
    [_progress cancel];
    return YES;
}

+ (NSArray *) phasesQueue {
    return @[];
}


@end
