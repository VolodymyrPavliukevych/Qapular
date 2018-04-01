//
//  QCCBaseAction.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCCBasePhase;
@class QCCBaseAction;

@protocol QCCBaseActionDataSource <NSObject>
@required
- (NSURL *) temeroryDirectoryURL;

@optional
- (NSUInteger) numberOfStepsForPhase:(QCCBasePhase *) phase InAction:(QCCBaseAction *) action;
- (NSString *) launchPathForStepNumber:(NSUInteger) stepNumber phase:(QCCBasePhase *) phase inAction:(QCCBaseAction *) action;
- (NSArray *) launchArgsForStepNumber:(NSUInteger) stepNumber phase:(QCCBasePhase *) phase inAction:(QCCBaseAction *) action;
- (NSString *) launchFolderPathForStepNumber:(NSUInteger) stepNumber phase:(QCCBasePhase *) phase inAction:(QCCBaseAction *) action;

@end

@interface QCCBaseAction : NSObject {
    NSArray         *_phasesArray;
    NSMutableArray  *_startedPhasesArray;
    Class           currentPhaseClass;
    NSEnumerator    *_phaseEnumerator;
}

@property (nonatomic, assign) id<QCCBaseActionDataSource>  dataSource;
@property (nonatomic, strong) NSProgress    *progress;
@property (nonatomic, copy) void (^ actionProgressBlock)(QCCBaseAction * action, NSProgress *progress, NSError *error);
@property (nonatomic, copy) void (^ actionReportBlock) (QCCBaseAction *action, QCCBasePhase *phase, NSDictionary *report);


- (BOOL) start;
- (BOOL) cancel;

+ (NSArray *) phasesQueue;

@end
