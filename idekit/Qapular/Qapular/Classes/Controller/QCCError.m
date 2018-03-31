//
//  QCCError.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCError.h"

@implementation QCCError

static NSString *const  QCCErrorDomain  =   @"com.qapular";

+ (NSError *) errorForCode:(QCCErrorCode) code {
    
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [QCCError localizedDescriptionForCode:code],
                                   NSLocalizedRecoverySuggestionErrorKey: [QCCError localizedRecoverySuggestionForCode:code],
                                   };
    
    
    NSError *error = [[NSError alloc] initWithDomain:QCCErrorDomain code:code userInfo:userInfo];
    
    return error;
    
}

+ (NSError *) errorForCode:(QCCErrorCode) code attempter:(id) attempter recoveryOptions:(NSArray *) recoveryOptions {
    if (!attempter || !recoveryOptions)
        return [QCCError errorForCode:code];
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: [QCCError localizedDescriptionForCode:code],
                               NSLocalizedRecoverySuggestionErrorKey: [QCCError localizedRecoverySuggestionForCode:code],
                               NSLocalizedRecoveryOptionsErrorKey: recoveryOptions,
                               NSRecoveryAttempterErrorKey:attempter
                               };
    
    
    NSError *error = [[NSError alloc] initWithDomain:QCCErrorDomain code:code userInfo:userInfo];

    return error;
    
}

+ (NSString *) localizedDescriptionForCode:(QCCErrorCode) code {

    switch (code) {
        case QCCErrorCodeProjectFolderExist:
            return NSLocalizedString(@"There is folder with that project's name.", nil);

        case QCCErrorCodeFolderExist:
            return NSLocalizedString(@"There is folder with that name.", nil);

        case QCCErrorCodeCanNotCreateFolder:
            return NSLocalizedString(@"Can't create folder.", nil);
            
        case QCCErrorCodeCanNotCreateFile:
            return NSLocalizedString(@"Can't create file on file system.", nil);
        case QCCErrorCodeNeedInstallPackage:
            return NSLocalizedString(@"Can't continue action", nil);
        case QCCErrorCodeCanNotInstallPackage:
            return NSLocalizedString(@"Can't continue installation", nil);
        case QCCErrorCodeTargetDinNotSelected:
            return NSLocalizedString(@"Can't continue upload", nil);
        case QCCErrorCodeTargetCanNotSupport:
            return NSLocalizedString(@"That target not supported for that action.", nil);
        case QCCErrorCodeActionTerminated:
            return NSLocalizedString(@"Action terminated.", nil);
        default:
            // DO NOT RETURN NIL!
            return NSLocalizedString(@"Unknown error", nil);
            break;
    }
}

+ (NSString *) localizedRecoverySuggestionForCode:(QCCErrorCode) code {
    switch (code) {
        case QCCErrorCodeProjectFolderExist:
            return NSLocalizedString(@"Please, try to set another name or you can replace that folder.", nil);

        case QCCErrorCodeFolderExist:
            return NSLocalizedString(@"Please, try to set another folder name.", nil);

        case QCCErrorCodeCanNotCreateFolder:
            return NSLocalizedString(@"Please, try to set another folder name.", nil);
            
        case QCCErrorCodeCanNotCreateFile:
            return NSLocalizedString(@"Please, try to set another file name.", nil);

        case QCCErrorCodeNeedInstallPackage:
            return NSLocalizedString(@"Please, open target manager (Target menu section) and install all packages for selected target.", nil);

        case QCCErrorCodeCanNotInstallPackage:
            return NSLocalizedString(@"Occur error while package installation, please send that information to us or try latest version", nil);
            
        case QCCErrorCodeTargetDinNotSelected:
            return NSLocalizedString(@"Please, select attached target board", nil);
            
        case QCCErrorCodeTargetCanNotSupport:
            return NSLocalizedString(@"Please, check right target, deployment configuration or target schema.", nil);

        case QCCErrorCodeActionTerminated:
            return NSLocalizedString(@"That is soft termination.", nil);
            
        default:
            // DO NOT RETURN NIL!
            return NSLocalizedString(@"Unknown error, no suggestion", nil);
            break;
    }
}



@end
