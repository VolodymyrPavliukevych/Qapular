//
//  QCCError.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavlyukevich on 5/10/15.
//  Copyright (c)  2014 Vladimir Pavlyukevich. All rights reserved.
//

#import "QCCActionKitError.h"

@implementation QCCActionKitError

static NSString *const  QCCErrorDomain  =   @"com.qapular.actionkit";

+ (NSError *) errorForCode:(QCCErrorCode) code {
    
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [QCCActionKitError localizedDescriptionForCode:code],
                                   NSLocalizedRecoverySuggestionErrorKey: [QCCActionKitError localizedRecoverySuggestionForCode:code],
                                   };
    
    
    NSError *error = [[NSError alloc] initWithDomain:QCCErrorDomain code:code userInfo:userInfo];
    
    return error;
    
}

+ (NSError *) errorForCode:(QCCErrorCode) code attempter:(id) attempter recoveryOptions:(NSArray *) recoveryOptions {
    if (!attempter || !recoveryOptions)
        return [QCCActionKitError errorForCode:code];
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: [QCCActionKitError localizedDescriptionForCode:code],
                               NSLocalizedRecoverySuggestionErrorKey: [QCCActionKitError localizedRecoverySuggestionForCode:code],
                               NSLocalizedRecoveryOptionsErrorKey: recoveryOptions,
                               NSRecoveryAttempterErrorKey:attempter
                               };
    
    
    NSError *error = [[NSError alloc] initWithDomain:QCCErrorDomain code:code userInfo:userInfo];

    return error;
    
}

+ (NSString *) localizedDescriptionForCode:(QCCErrorCode) code {

    switch (code) {
        case QCCErrorCodePhaseError:
            return NSLocalizedString(@"There is error in phase", nil);
            
        default:
            // DO NOT RETURN NIL!
            return NSLocalizedString(@"Unknown error", nil);
            break;
    }
}

+ (NSString *) localizedRecoverySuggestionForCode:(QCCErrorCode) code {
    switch (code) {
        case QCCErrorCodePhaseError:
            return NSLocalizedString(@"Please, analise your debug information.", nil);

        default:
            // DO NOT RETURN NIL!
            return NSLocalizedString(@"Unknown error, no suggestion", nil);
            break;
    }
}



@end
