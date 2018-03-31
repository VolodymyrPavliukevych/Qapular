//
//  QCCBracketMachine.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QCCodeStorage;


@interface QCCBracketMachine : NSObject

extern NSString *const QCCBracketMachineUpdatedNotification;

- (instancetype) initWithStorage:(QCCodeStorage *) codeStorage;
- (void) updateIndexesForRange:(NSRange)range withString:(NSString *) newStrings;

- (NSArray *) closedBrackets;
- (NSArray *) openBrackets;
- (NSArray *) bracketPairs;

@end
