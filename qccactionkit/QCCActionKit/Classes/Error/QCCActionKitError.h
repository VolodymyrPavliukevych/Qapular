//
//  QCCError.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavlyukevich on 5/10/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    QCCErrorCodeUnknown,
    QCCErrorCodePhaseError          = 200
    
} QCCErrorCode;


@interface QCCActionKitError : NSObject

+ (NSError *) errorForCode:(QCCErrorCode) code;
+ (NSError *) errorForCode:(QCCErrorCode) code attempter:(id) attempter recoveryOptions:(NSArray *) recoveryOptions;

@end
