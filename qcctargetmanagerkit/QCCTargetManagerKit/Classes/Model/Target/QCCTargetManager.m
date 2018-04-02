//
//  QCCTargetManager.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCTargetManager.h"
#import "QCCPackage.h"
#import "QCCSchema.h"
#import "QCCTarget.h"
#import "QCComplexURL.h"
#import "QCCPortManager.h"
#import "QCCSerialConsoleViewController.h"


@interface QCCTargetManager() {
    NSDictionary        *_rawContentDictionary;
    NSMutableDictionary *_packages;
    NSMutableDictionary *_targets;
    QCCPortManager      *_portManager;
    
    
    QCCSerialConsoleViewController *_serialConsoleViewController;
}

@end

@implementation QCCTargetManager

NSString *const QCCTargetManagerKnownTargetsKey = @"QCCTargetManagerKnownTargets";
NSString *const QCCTargetManagerUnknownTargetsKey = @"QCCTargetManagerUnknownTargets";

static NSString *const QCCTargetManagerStorageFolderName = @"targets";
static NSString *const QCCTargetManagerPlistFileName = @"TargetManager.plist";

static QCCTargetManager *sharedSingleton = nil;


//static NSString *const QCCTargetManager;
static NSString *const QCCTargetManagerVersionKey = @"QCCTargetManagerVersion";
static NSString *const QCCTargetManagerPackagesKey = @"QCCTargetManagerPackages";
static NSString *const QCCTargetManagerTargetsKey = @"QCCTargetManagerTargets";


+ (instancetype) defaultManager {

    if(!sharedSingleton){
        sharedSingleton = [[QCCTargetManager alloc] initWithFileURL:[NSURL fileURLWithPath:[QCCTargetManager localPlistPath]]];
    }
    
    return sharedSingleton;

}

+ (NSString *) localPlistPath {
    
    NSString *storageFolder = [self storageFolder];
    NSString *localPlistPath = [storageFolder stringByAppendingPathComponent:QCCTargetManagerPlistFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPlistPath isDirectory:nil]) {
        if (![QCCTargetManager copyTargetManagerPlistToPath:localPlistPath])
            return nil;
        else
            return localPlistPath;
    }

    NSDictionary *bundleOptions = [NSDictionary dictionaryWithContentsOfFile:[self defaultPlistPath]];
    NSNumber *bundleFileVersion = bundleOptions[QCCTargetManagerVersionKey];
    
    NSDictionary *localOptions = [NSDictionary dictionaryWithContentsOfFile:localPlistPath];
    NSNumber *localFileVersion;
    if (localOptions && localOptions[QCCTargetManagerVersionKey])
        localFileVersion = localOptions[QCCTargetManagerVersionKey];
    
    if (localFileVersion && [localFileVersion isKindOfClass:[NSNumber class]])
        if ([localFileVersion doubleValue] == [bundleFileVersion doubleValue])
            return localPlistPath;
    
    
    if ([QCCTargetManager copyTargetManagerPlistToPath:localPlistPath])
        return localPlistPath;

    return nil;
}

+ (BOOL) copyTargetManagerPlistToPath:(NSString *) path {
    NSError *error;
    
    NSURL *sourceFileURL = [NSURL fileURLWithPath:[QCCTargetManager defaultPlistPath]];
    NSURL *destinationFileURL = [NSURL fileURLWithPath:path];

    if([[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    
    BOOL result = [[NSFileManager defaultManager] copyItemAtURL:sourceFileURL toURL:destinationFileURL error:&error];

    if (error)
        NSLog(@"Error: %@", error);
    return result;
}


+ (NSString *) defaultPlistPath {
    return [[NSBundle bundleForClass:[self class]] pathForResource:[QCCTargetManagerPlistFileName stringByDeletingPathExtension]
                                                            ofType:[QCCTargetManagerPlistFileName pathExtension]];
}



- (id) init {

    if (sharedSingleton)
        return sharedSingleton;

    self = [super init];
    if(self) {
    
    }
    
   sharedSingleton = self;
    return self;
}


- (instancetype) initWithFileURL:(NSURL *) optionsFileURL {
    if (!optionsFileURL)
        return nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[optionsFileURL path]])
        return nil;

    self = [super init];
    
    if (self) {
        NSError *error;
        NSData *dataContent = [NSData dataWithContentsOfURL:optionsFileURL];
        NSDictionary *options =  [NSPropertyListSerialization propertyListWithData:dataContent
                                                                           options:0
                                                                            format:nil
                                                                             error:&error];
        
        if (error || !options)
            return nil;
        
        _rawContentDictionary = [NSDictionary dictionaryWithDictionary:options];
        _portManager = [QCCPortManager new];
    }
    
    return self;
}

#pragma mark - Container
- (NSString *) version {
    return _rawContentDictionary[QCCTargetManagerVersionKey];
}


- (NSDictionary *) packagesDictionary {
    return _rawContentDictionary[QCCTargetManagerPackagesKey];
}

- (NSDictionary *) targetsDictionary {
    return _rawContentDictionary[QCCTargetManagerTargetsKey];
}

- (NSUInteger) packagesCount {
    return [[[self packagesDictionary] allKeys] count];
}

- (NSUInteger) targetsCount {
    return [[[self targetsDictionary] allKeys] count];
}

- (NSDictionary *) packages {
    
    if (_packages)
        return _packages;
    
    _packages = [NSMutableDictionary new];
    NSDictionary *packagesDictionary = [self packagesDictionary];
    for (NSString *packageIdentifier in [packagesDictionary allKeys]) {
    
        NSDictionary *packageDictionary = packagesDictionary[packageIdentifier];
        QCCPackage *package = [[QCCPackage alloc] initWithDictionary:packageDictionary];

        if (package)
            _packages[packageIdentifier] = package;
    }
    
    return _packages;
}

- (NSDictionary *) targets {
    if (_targets)
        return _targets;

    _targets = [NSMutableDictionary new];

    NSDictionary *targetsDictionary = [self targetsDictionary];
    for (NSString *targetIdentifier in [targetsDictionary allKeys]) {
        
        NSDictionary *targetDictionary = targetsDictionary[targetIdentifier];
        QCCTarget *target = [[QCCTarget alloc] initWithDictionary:targetDictionary];

        if (target)
            _targets[targetIdentifier] = target;
    }
    
    return _targets;

}

- (NSString *) processSchemaURL:(NSString *) string {

    return nil;
}

#pragma mark - Working with ports
- (NSDictionary *) attachedTargets {
    
    NSMutableDictionary *attachedTargets = [NSMutableDictionary new];
    NSMutableDictionary *knownTargets = [NSMutableDictionary new];
    
    NSMutableDictionary *unknownTargets = [NSMutableDictionary new];
    
    for (NSDictionary *port in [_portManager availablePorts]) {
        
        NSNumber *vidNumber = port[QCCPortVIDKey];
        NSNumber *pidNumber = port[QCCPortPIDKey];
        NSString *bsdPortName = port[QCCPortBSDNameKey];
        
        if (!vidNumber || !pidNumber || !bsdPortName)
            continue;
        
        for (QCCTarget *target in [self.targets allValues]) {
            for (NSString *generationKey in [target.generations allKeys]) {
                NSDictionary *generationSpecification = target.generations[generationKey];
                
                NSNumber *targetVIDNumber = generationSpecification[QCCTargetVIDNumberKey];
                NSNumber *targetPIDNumber = generationSpecification[QCCTargetPIDNumberKey];

                if ([vidNumber isEqualToNumber:targetVIDNumber] && [pidNumber isEqualToNumber:targetPIDNumber]) {
                    knownTargets[bsdPortName] = target;
                    break;
                }
                    
                if (knownTargets[bsdPortName])
                    continue;
            }
        }
        
        if (!knownTargets[bsdPortName])
            unknownTargets[bsdPortName] = port;
        
    }
    
    attachedTargets[QCCTargetManagerKnownTargetsKey] = knownTargets;
    attachedTargets[QCCTargetManagerUnknownTargetsKey] = unknownTargets;
    
    return attachedTargets;
}

- (QCComplexURL *) processPackagePath:(NSString *) path {
    QCComplexURL *packageURL = [[QCComplexURL alloc] initWithString:path packageManager:^QCCPackage *(NSString *identifier) {
        return [self packages][identifier];
    }];
    return packageURL;
}


#pragma mark - Helper
+ (NSString *) storageFolder {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray* applicationSupportFolders = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if ([applicationSupportFolders count] == 0)
        return nil;
    
    NSString *customBundleIdentifier  = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *mainBundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *bundleIdentifier = (mainBundleIdentifier ? mainBundleIdentifier : customBundleIdentifier);
    
    NSError *error;
    NSURL *applicationSupportFolder = [applicationSupportFolders firstObject];
    NSString *rootFolderPath = [[applicationSupportFolder path] stringByAppendingPathComponent:bundleIdentifier];
    
    if (![fileManager fileExistsAtPath:rootFolderPath isDirectory:nil])
        if (![fileManager createDirectoryAtPath:rootFolderPath withIntermediateDirectories:YES attributes:nil error:&error])
            return nil;
    
    NSString *packageFolderPath = [rootFolderPath stringByAppendingPathComponent:QCCTargetManagerStorageFolderName];
    if (![fileManager fileExistsAtPath:packageFolderPath isDirectory:nil])
        if (![fileManager createDirectoryAtPath:packageFolderPath withIntermediateDirectories:YES attributes:nil error:&error])
            return nil;
    
    return packageFolderPath;
}

#pragma mark - Serial Console

-(NSViewController *)serialConsoleViewController {
    if(!_serialConsoleViewController) {
        if (!_portManager)
            return nil;
        _serialConsoleViewController = [QCCSerialConsoleViewController consoleWithPortManager:_portManager];
    }
    
    return _serialConsoleViewController;
}

- (void) consoleWithBSDName:(NSString *) BSDname pause:(BOOL) pause {
    [_portManager consoleWithBSDName:BSDname pause:pause];
}


@end
