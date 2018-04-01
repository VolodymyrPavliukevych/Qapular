//
//  QCCUploadAction.m
//  QCCActionKit
//
//  Created by Vladimir Pavlyukevich on 7/20/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCUploadAction.h"
#import "QCCUploadPhase.h"


@implementation QCCUploadAction
+(NSArray *)phasesQueue {
    return @[[QCCUploadPhase class]];
}

@end
