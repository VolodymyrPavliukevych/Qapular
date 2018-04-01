//
//  QCCBaseAction+Private.h
//  QCCActionKit
//
//  Created by Volodymyr Pavlyukevich on 7/11/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <QCCActionKit/QCCActionKit.h>

@interface QCCBaseAction (Private)

- (void) launchCurrentPhase;
- (Class) nextPhase;
@end
