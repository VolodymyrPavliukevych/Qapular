//
//  QCCBasePhase.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QCCTaskManagerKit/QCCTaskManagerKit.h>
#import "QCCBaseAction.h"

typedef enum : NSUInteger {
    QCCPhaseResultUnknown,
    QCCPhaseResultSuccess,
    QCCPhaseResultFail
} QCCPhaseResult;

@interface QCCBasePhase : NSObject {
    QCCBaseAction       * _action;
    QCCTaskManager      *_taskManager;
    QCCPhaseResult      _result;
}


extern NSString *const QCCPhaseReportComandKey;
extern NSString *const QCCPhaseReportComandArgsKey;
extern NSString *const QCCPhaseReportOutputKey;
extern NSString *const QCCPhaseReportErrorKey;
extern NSString *const QCCPhaseReportExtraKey;

@property (nonatomic, readonly) QCCPhaseResult result;
@property (nonatomic, copy) void (^ phaseProgressBlock)(QCCBasePhase * phase);
@property (nonatomic, copy) void (^ phaseFinishedBlock)(QCCBasePhase * phase);

// NSProgress handler
@property (nonatomic, copy) void (^cancellationHandler)(void);
@property (nonatomic, copy) void (^pausingHandler)(void);

+ (NSString *) phaseTypeIdentefier;

// Do not call super launch,
// Is is calls phaseFinishedBlock(self);
- (void) launch;
+ (NSString *) progressLocalizedDescription;
@end
