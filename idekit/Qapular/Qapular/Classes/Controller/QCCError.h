//
//  QCCError.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    QCCErrorCodeUnknown,
    QCCErrorCodeProjectFolderExist      = 100,
    QCCErrorCodeFolderExist             = 101,
    QCCErrorCodeCanNotCreateFolder      = 102,
    QCCErrorCodeCanNotCreateFile        = 103,
    QCCErrorCodeNeedInstallPackage      = 104,
    QCCErrorCodeCanNotInstallPackage    = 105,
    QCCErrorCodeTargetDinNotSelected    = 106,
    QCCErrorCodeTargetCanNotSupport     = 107,
    QCCErrorCodeActionTerminated        = 108


} QCCErrorCode;


@interface QCCError : NSObject

+ (NSError *) errorForCode:(QCCErrorCode) code;
+ (NSError *) errorForCode:(QCCErrorCode) code attempter:(id) attempter recoveryOptions:(NSArray *) recoveryOptions;

@end
