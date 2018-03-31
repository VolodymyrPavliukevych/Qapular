//
//  ActionKitTests.m
//  ActionKitTests
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ActionKit/ActionKit.h>
#import <ActionKit/ActionKit-Swift.h>
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>


@interface ActionKitTests : XCTestCase
@end

@interface ActionKitTests () <QCCActionDataSource> {
    QCCAction           *_mainAction;
    NSURL               *_temeroryDirectoryURL;
    QCCProjectGroup     *_temeroryDirectoryGroup;
}

@end

@implementation ActionKitTests

- (void)setUp {
    [super setUp];

    NSError *error;
    NSString *tempUUID = [[[NSProcessInfo processInfo] globallyUniqueString] lowercaseString];
    tempUUID = [tempUUID stringByAppendingString:@"/"];
    NSURL *directoryURL = [[NSURL alloc] initWithString:[NSTemporaryDirectory() stringByAppendingPathComponent:tempUUID]];
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:directoryURL.path withIntermediateDirectories:YES attributes:nil error:&error];
    if (result)
        _temeroryDirectoryURL = directoryURL;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"build" ofType:@"bundle"];
    
    NSArray *sources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    for (NSString *sourceFile in sources) {
        NSString *filePath = [path stringByAppendingPathComponent:sourceFile];
        [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:[_temeroryDirectoryURL.path stringByAppendingPathComponent:sourceFile] error:&error];
    }

    
    _mainAction = [[QCCAction alloc] initWithIdentifier:[NSUUID UUID].UUIDString
                                                   type:QCCActionTypeClear
                                             dataSource:self];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void) testBitMask {

    QCCPhaseObjectType type = QCCPhaseObjectTypeAttachedSource;
    type |= QCCPhaseObjectTypePostPhaseArtefact;
    type ^= QCCPhaseObjectTypeAttachedSource;
    
    if (type & QCCPhaseObjectTypeAttachedSource) {
        NSLog(@"type: %li", (long)type);
    }
    
    if (type & QCCPhaseObjectTypePostPhaseArtefact) {
        NSLog(@"type: %li", (long)type);
    }
    
    if (type & QCCPhaseObjectTypeProjectSource) {
        XCTAssert((NO), @"Fail");

    }
    
    XCTAssert((YES), @"Pass");
}

- (void)testExample {
    XCTestExpectation *documentOpenExpectation = [self expectationWithDescription:@"task is progress"];

    _mainAction.actionProgressClosure = ^(BaseAction *action, NSProgress *progress, NSError *error) {
        NSLog(@"action: %@", action);
        NSLog(@"progress totalUnitCount: %lli completedUnitCount : %lli", progress.totalUnitCount, progress.completedUnitCount);
        if (progress.totalUnitCount == progress.completedUnitCount) {
            [documentOpenExpectation fulfill];
        }

    };
    

    
    [_mainAction start];
    
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    }];

    XCTAssert((YES), @"Pass");

}


#pragma mark - QCCActionDataSource
-(NSInteger)numberOfPhaseInAction:(BaseAction *)action {
    return 2;
}

-(NSURL *)temporaryDirectoryURL:(BaseAction *)action {
    return _temeroryDirectoryURL;
}

-(enum QCCPhaseObjectType)phaseObjectTypeForAction:(BaseAction *)action phase:(BasePhase *)phase {
    return  QCCPhaseObjectTypeProjectSource;
}


-(NSString *)phaseIdentifierForAction:(BaseAction *)action atIndex:(NSInteger)index {
    return [NSUUID UUID].UUIDString;
}

-(enum QCCPhaseProcessingQueueType)phaseQueueTypeForAction:(BaseAction *)action atIndex:(NSInteger)index {
//    if (index > 5)
        return QCCPhaseProcessingQueueTypeSerial;
//    else
//        return QCCPhaseProcessingQueueTypeConcurrent;
    
}
-(enum QCCObjectProcessingQueueType)objectQueueTypeForAction:(BaseAction *)action phase:(BasePhase *)phase {
    return QCCObjectProcessingQueueTypeSerial;
}

-(NSArray<QCCProjectEssence *> *)objectsForProcessingByAction:(BaseAction *)action phase:(BasePhase *)phase {
    return [[self projectSourceSet] allObjects];
}

- (NSArray <NSString *> * __nullable)objectProducingPhaseIdentifiersForAction:(BaseAction * __nonnull)action phase:(BasePhase * _Nonnull)phase processingQueueType:(enum QCCObjectProcessingQueueType)processingQueueType {
    return @[@""];
}

-(NSString *)toolForProcessingByAction:(BaseAction *)action phase:(BasePhase *)phase UTTypeString:(NSString *)UTTypeString {
    return @"/usr/bin/tar";
}

- (NSArray<NSString *> * __nonnull)propertiesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[@"-P", @"-v", @"-c"];
}

- (NSArray<NSString *> * __nonnull)objectPrefixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[];
}

- (NSArray<NSString *> * __nonnull)objectPostfixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[];
}

-(QCCProjectEssence *)artefactForProcessingByAction:(BaseAction *)action phase:(BasePhase *)phase fromObject:(QCCProjectEssence *)object {
    NSString *file = [object.path stringByAppendingString:@".tar"];
    QCCProjectFile *artefactFile = [[QCCProjectFile alloc] initWithDictionary:@{QCCProjectSourcePathKey : file} identifier:nil];
    artefactFile.parent = [self temeroryDirectoryGroup];
    return artefactFile;
}

- (NSArray<NSString *> * __nonnull)artefactPrefixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[@"-f"];
}

- (NSArray<NSString *> * __nonnull)artefactPostfixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[];
}

-(BOOL)shouldReverseObjectAndArtefactSectionByAction:(BaseAction *)action phase:(BasePhase *)phase forObject:(QCCProjectEssence *)object {
    return YES;
}

#pragma mark - Test helper
-(NSSet *)projectSourceSet {
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[self sourceForString:_temeroryDirectoryURL.path withGroup:@"src"]];
    
    return [NSSet setWithArray:array];
}

- (QCCProjectGroup *) temeroryDirectoryGroup {
    if (!_temeroryDirectoryGroup) {
        
        
        _temeroryDirectoryGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey:[_temeroryDirectoryURL lastPathComponent],
                                                                                QCCProjectSourceRootFileKey : @(YES)}
                                                                   identifier:nil
                                                                   projectURL:[_temeroryDirectoryURL URLByDeletingLastPathComponent]];
    }
    return _temeroryDirectoryGroup;

}


- (QCCProjectGroup *) sourceForString:(NSString *) path withGroup:(NSString *) groupName {
    NSURL *url = [[NSURL alloc] initWithString:path];
    
    QCCProjectGroup *arduinoCoreSourceGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey: groupName,
                                                                                            QCCProjectSourceRootFileKey : @(YES)}
                                                                               identifier:nil
                                                                               projectURL:url];
    NSError *error;
    NSString *folder = [arduinoCoreSourceGroup.projectFolderURL.path stringByAppendingPathComponent:arduinoCoreSourceGroup.path];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
    
    for (NSString *file in files) {
        
        if ([[file pathExtension] isEqualToString:@"cpp"] || [[file pathExtension] isEqualToString:@"c"] || [[file pathExtension] isEqualToString:@"S"]) {
            QCCProjectFile *projectFile = [[QCCProjectFile alloc] initWithDictionary:@{QCCProjectSourcePathKey : file} identifier:nil];
            projectFile.parent = arduinoCoreSourceGroup;
        }
    }
    return arduinoCoreSourceGroup;
}

@end
