//
//  QCCTargetManagerKitTests.m
//  QCCTargetManagerKitTests
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>

@interface QCCTargetManagerKitTests : XCTestCase {
    QCCTargetManager    *_targetManager;
}

@end

@implementation QCCTargetManagerKitTests

- (void)setUp {
    [super setUp];

    _targetManager = [QCCTargetManager defaultManager];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testPortManager {
    NSLog(@"QCCTargetManager: %@", _targetManager);
    NSLog(@"attachedTargets: %@", _targetManager.attachedTargets);
}


/*
- (void) testPorts {
    
    QCCTargetManager *targetManager = [QCCTargetManager defaultManager];
    NSDictionary *targetManagerKnownTargets = [targetManager attachedTargets][QCCTargetManagerKnownTargetsKey];
    for (NSString *portName in [targetManagerKnownTargets allKeys]) {
        
        QCCTarget *target = targetManagerKnownTargets[portName];
        [self schemaProviderForTarget:target targetManager:targetManager];
        
        NSSet *dependencySet = [target.schema dependencyPackageIdentifierSet];
        NSLog(@"\ntarget: '%@' \ndependencySet: %@\n\n", target.name, dependencySet);
        for (NSString *packageIdentifier in [dependencySet allObjects]){
            QCCPackage *package = [targetManager packages][packageIdentifier];
            if (!package)
                continue;
            
            NSLog(@"package: '%@' isInstalled: %@", package.name, ([package isInstalled] ? @"YES" : @"NO"));
        }
    }
    
    XCTAssert(YES, @"\n\nPass");

}
*/
- (void) schemaProviderForTarget:(QCCTarget *) target targetManager:(QCCTargetManager *) targetManager {

    QCCSchema *schema = target.schema;
    
//    for (NSString *path in [[schema sourceSet] allObjects]) {
//        NSLog(@"source path: %@", [targetManager processPackagePath:path]);
//    }
//    
//    for (NSString *path in [[schema includeSet] allObjects]) {
//        NSLog(@"include path: %@", [targetManager processPackagePath:path]);
//    }
//    
//    for (NSString *path in [[schema librarySet] allObjects]) {
//        NSLog(@"library path: %@", [targetManager processPackagePath:path]);
//    }
    NSString *identefier = [[schema.dependencyPackageIdentifierSet allObjects] firstObject];
    QCCPackage *package = [targetManager packages][identefier];
    
    if (!package.isInstalled) {
        
        __block int percent = 0;
        
        package.downloadProgressBlock = ^(QCCPackageDownloadState state, NSError *error, int64_t totalBytesWritten, int64_t expectedTotalBytes) {
            int value = (int)((100 * totalBytesWritten) / expectedTotalBytes);
            if (percent < value) {
                printf("download %lu %lluKb / %lluKb %i %%\n", state, totalBytesWritten / 1024, expectedTotalBytes /1024, value);
                percent++;
            }
            
        };
        
        package.unpackProgressBlock = ^(QCCPackageUnpackState state) {
            NSLog(@"unpackProgressState: %lu", state);
        };

        
        __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [package installWithStateBlock:^(QCCBasePackage *package, QCCPackageInstallState state, NSError *error) {
            NSLog(@"package: %@, %lu, %@", package.identifier, state, error);
            if (state == QCCPackageInstallStateSuccessFinish || state == QCCPackageInstallStateFinishWithError)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_semaphore_signal(semaphore);
                });
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    /*
    NSLog(@"kUTTypeAssemblyLanguageSource args: %lu ", [[schema compilingArgsForUTTypeString:kUTTypeAssemblyLanguageSource] count]);
    NSLog(@"kUTTypeCPlusPlusSource: %lu ", [[schema compilingArgsForUTTypeString:kUTTypeCPlusPlusSource] count]);
    NSLog(@"kUTTypeCSource: %lu ", [[schema compilingArgsForUTTypeString:kUTTypeCSource] count]);
    
    NSLog(@"kUTTypeAssemblyLanguageSource tool: %@", [[QCCPackageURL alloc] initWithString:[schema compileToolPathForUTTString:kUTTypeAssemblyLanguageSource]
                                                                            packageManager:^QCCPackage *(NSString *identifier) {
                                                                                return [targetManager packages][identifier];
                                                                            }]);
    
    NSLog(@"kUTTypeCPlusPlusSource tool: %@", [[QCCPackageURL alloc] initWithString:[schema compileToolPathForUTTString:kUTTypeCPlusPlusSource]
                                                                     packageManager:^QCCPackage *(NSString *identifier) {
                                                                         return [targetManager packages][identifier];
                                                                     }]);
    NSLog(@"kUTTypeCSource tool: %@", [[QCCPackageURL alloc] initWithString:[schema compileToolPathForUTTString:kUTTypeCSource]
                                                             packageManager:^QCCPackage *(NSString *identifier) {
                                                                 return [targetManager packages][identifier];
                                                             }]);
    
    
    NSLog(@"Archive tool : %@", [[QCCPackageURL alloc] initWithString:[schema archiveToolPath]
                                                       packageManager:^QCCPackage *(NSString *identifier) {
                                                           return [targetManager packages][identifier];
                                                       }]);
    
    NSLog(@"executableLinkableFormatToolPath: %@", [[QCCPackageURL alloc] initWithString:[schema executableLinkableFormatToolPath]
                                                                          packageManager:^QCCPackage *(NSString *identifier) {
                                                                              return [targetManager packages][identifier];
                                                                          }]);
    
    NSLog(@"objCopyToolPath: %@", [[QCCPackageURL alloc] initWithString:[schema objCopyToolPath]
                                                         packageManager:^QCCPackage *(NSString *identifier) {
                                                             return [targetManager packages][identifier];
                                                         }]);

    
    NSLog(@"Archive tool args: %@", [schema archiveToolArgs]);
    
    NSLog(@"includeParametrName: %@", [schema includeParametrName]);
    NSLog(@"compileOutputParametrName: %@", [schema compileOutputParametrName]);
    NSLog(@"compileOutputPathExtension: %@", [schema compileOutputPathExtension]);
    NSLog(@"executableLinkableFormatToolArgs: %@", [schema executableLinkableFormatToolArgs]);
    NSLog(@"compileLibraryParametrName: %@", [schema compileLibraryParametrName]);
    NSLog(@"objCopyToolArgs: %@", [schema objCopyToolArgs]);
    NSLog(@"objCopyToolEEPArgs: %@", [schema objCopyToolEEPArgs]);
    
    for (NSUInteger idx = 0; idx < [schema numberOfUploadStep]; idx++ ) {
        NSLog(@"%@", [schema uploadLaunchPathForStepIndex:idx]);
    
        for (NSDictionary *launchArg in [schema uploadLaunchArgsForStepIndex:idx]) {
            QCCPackageURL  *packageURL = [[QCCPackageURL alloc] initWithString:launchArg[QCCArgParamKey]
                                                                packageManager:^QCCPackage *(NSString *identifier) {
                                                                    return [targetManager packages][identifier];
                                                                }
                                          environment:^NSString *(NSString *environmentKey) {
                                              return @"---";
                                          }];
            NSLog(@"%@ %@", launchArg[QCCArgParamKey], packageURL);
        }
    }
    */
}

- (void) testTargetmanager {
    
//    QCCTargetManager *targetManager = [QCCTargetManager defaultManager];
//    
//    NSDictionary *packages = [targetManager packages];
//    for (NSString *packageIdentifier in [packages allKeys]) {
//        
//        QCCPackage *package = packages[packageIdentifier];
//
//        NSLog(@"\n\nidentifier: %@ %@ %@",
//              packageIdentifier,
//              [package toolPathForKey:QCCPackageCPPCompileToolKey],
//              ([package isInstalled] ? @"YES" : @"NO"));
//        
//    }
//    
//    NSDictionary *targets = [targetManager targets];
//    
//    for (NSString *targetIdentifier in [targets allKeys]) {
//        QCCTarget *target = targets[targetIdentifier];
//        for (NSString *key in [target.schema availableActionKeys]) {
//            NSDictionary *dict = [target.schema actionIdentifier:key phaseForIndex:0];
//            NSLog(@"%@", dict[QCCPhaseIdentifierKey]);
//            NSDictionary *dictPhase = [target.schema actionIdentifier:key phaseForIdentifier:dict[QCCPhaseIdentifierKey]];
//            NSLog(@"%@", dictPhase);
//            
//        }
//        
//
//    }

    XCTAssert(YES, @"\n\nPass");

}
/*
- (void)testExample {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

//    NSURL *url = [[NSURL alloc] initWithString:@"http://downloadmirror.intel.com/24806/eng/edison-toolchain-linux64-1.6.2-1.0.tar.bz2"];
//    NSURL *url = [[NSURL alloc] initWithString:@"http://downloads.arduino.cc/bossac-1.5-arduino2-mingw32.tar.gz"];
    NSURL *url = [[NSURL alloc] initWithString:@"http://downloads.arduino.cc/cores/avr-1.6.2.tar.bz2"];
    
    QCCBasePackage *package = [[QCCBasePackage alloc] initWithDictionary:@{QCCPackageURLKey : @[url],
                                                                           QCCPackageVersionKey : @(1),
                                                                           QCCPackageContentVersionKey : @(1),
                                                                           QCCPackageIdentifierKey : @"test_package",
                                                                           QCCPackageMD5HashKey: @""}];
    
    __block int percent = 0;
    
    package.downloadProgressBlock = ^(QCCPackageDownloadState state, NSError *error, int64_t totalBytesWritten, int64_t expectedTotalBytes) {
        int value = (int)((100 * totalBytesWritten) / expectedTotalBytes);
        if (percent < value) {
            printf("download %lu %lluKb / %lluKb %i %%\n", state, totalBytesWritten / 1024, expectedTotalBytes /1024, value);
            percent++;
        }
        
    };
    
    package.unpackProgressBlock = ^(QCCPackageUnpackState state) {
        NSLog(@"unpackProgressState: %lu", state);
    };
 
    [package installWithStateBlock:^(QCCBasePackage *package, QCCPackageInstallState state, NSError *error) {
        NSLog(@"package: %@, %lu, %@", package.identifier, state, error);
        if (state == QCCPackageInstallStateSuccessFinish || state == QCCPackageInstallStateFinishWithError)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_semaphore_signal(semaphore);
            });
        
    }];
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
    NSLog(@"installed from URL: %@", [package installedURLString]);
    XCTAssert([package isInstalled], @"Pass");
}
*/
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
