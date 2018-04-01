//
//  QCCBaseAction+Private.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCBaseAction+Private.h"
#import "QCCBasePhase+Private.h"
#import "QCCActionKitError.h"

@implementation QCCBaseAction (Private)

-(void)launchCurrentPhase {
    
    if (currentPhaseClass == nil) {
        self.progress.completedUnitCount = self.progress.totalUnitCount;
        self.actionProgressBlock(self, self.progress, nil);
        return;
    }
    
    QCCBasePhase *phase = [[currentPhaseClass alloc] init];
    phase.action = self;
    
//    [_startedPhasesArray addObject:phase];
    
    self.progress.localizedDescription = [[phase class] progressLocalizedDescription];

    phase.phaseFinishedBlock = ^(QCCBasePhase * phase) {
        if (phase.result == QCCPhaseResultFail) {
            phase.action.actionProgressBlock(phase.action, phase.action.progress, [QCCActionKitError errorForCode:QCCErrorCodePhaseError]);
            return;
        }
            

        Class nextPhase = [self nextPhase];
        if(!nextPhase) {
            // action finished
        }
    };
    
    phase.phaseProgressBlock = ^(QCCBasePhase *phase) {
        self.actionProgressBlock(self, self.progress, nil);
    };
    
    self.progress.cancellationHandler = phase.cancellationHandler;
    self.progress.pausingHandler = phase.pausingHandler;
    
    [phase launch];
}


- (Class) nextPhase {
    if (!_phaseEnumerator)
        _phaseEnumerator = _phasesArray.objectEnumerator;

    
    Class next = [_phaseEnumerator nextObject];
    
    currentPhaseClass = next;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self launchCurrentPhase];
    });
    
    return currentPhaseClass;
}


@end
