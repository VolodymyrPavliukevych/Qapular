//
//  QCCClearAction.m
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCClearAction.h"
#import "QCCClearPhase.h"


@implementation QCCClearAction

+(NSArray *)phasesQueue {
    return @[[QCCClearPhase class]];
}


@end
