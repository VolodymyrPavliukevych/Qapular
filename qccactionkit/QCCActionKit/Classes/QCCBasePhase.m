//
//  QCCBasePhase.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCBasePhase.h"

NSString *const QCCPhaseReportComandKey     = @"QCCPhaseReportComand";
NSString *const QCCPhaseReportComandArgsKey = @"QCCPhaseReportComandArgs";
NSString *const QCCPhaseReportOutputKey     = @"QCCPhaseReportOutput";
NSString *const QCCPhaseReportErrorKey      = @"QCCPhaseReportError";
NSString *const QCCPhaseReportExtraKey      = @"QCCPhaseReportExtra";


@implementation QCCBasePhase

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (NSString *) phaseTypeIdentefier {
    return NSStringFromClass([self class]);
}

-(void)launch {
    self.phaseFinishedBlock(self);
}

-(void (^)(void))cancellationHandler {
    return ^(void) {
        NSLog(@"class: %@ %s", NSStringFromClass([self class]), __FUNCTION__);
    };
}

-(void (^)(void))pausingHandler {
    return ^(void) {
        NSLog(@"class: %@ %s", NSStringFromClass([self class]), __FUNCTION__);
    };
}

-(void)setAction:(id)action {
    _action = action;
}
-(id)action {
    return _action;
}

+ (NSString *) progressLocalizedDescription {
    return NSLocalizedString(@"There isn't any description.", @"Phase description.");
}

-(QCCPhaseResult)result {
    return _result;
}

@end
