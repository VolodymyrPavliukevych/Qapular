//
//  QCCProjectProcessor+ActionDataSource.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavlyukevich on 2/26/16.
//  Copyright © 2016 Qapular. All rights reserved.
//

#import "QCCProjectProcessor+ActionDataSource.h"
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>


@implementation QCCProjectProcessor (ActionDataSource)

- (NSDictionary *) phaseDictionaryForAction:(BaseAction *)action phase:(BasePhase *)phase {
    NSDictionary *phaseDictionary = [[self deploymentSchema] actionIdentifier:action.identifier
                                                           phaseForIdentifier:phase.identifier];
    return phaseDictionary;
}

#pragma mark - QCCActionDataSource

-(NSInteger)numberOfPhaseInAction:(BaseAction *)action {
    return 2;
}

-(NSURL *)temporaryDirectoryURL:(BaseAction *)action {
    return [self buildTemporaryFolderURL];
}

-(enum QCCPhaseObjectType)phaseObjectTypeForAction:(BaseAction *)action phase:(BasePhase *)phase {
    
    
//    QCCPhaseObjectTypeProjectSource = 0,
//    QCCPhaseObjectTypeAttachedSource = 1,
//    QCCPhaseObjectTypePostPhaseArtifact = 2,
//    NSDictionary *phase = [self phaseDictionaryForAction:action phase:phase];
//    [[self deploymentSchema] phaseObjectTypeForPhase:phase]

    return 0;
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
    return nil;//[[self projectSourceSet] allObjects];
}

- (NSString * __nullable)objectProducingPhaseIdentifierForAction:(BaseAction * __nonnull)action phase:(BasePhase * _Nonnull)phase processingQueueType:(enum QCCObjectProcessingQueueType)processingQueueType {
    return @"";
}

-(NSString *)toolForProcessingByAction:(BaseAction *)action phase:(BasePhase *)phase UTTypeString:(NSString *)UTTypeString {
    return @"/usr/bin/tar";
}

- (NSArray<NSString *> * __nonnull)parametrsForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[@"-P", @"-v", @"-c"];
}

- (NSArray<NSString *> * __nonnull)objectPrefixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[];
}

- (NSArray<NSString *> * __nonnull)objectPostfixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[];
}

-(QCCProjectEssence *)artifactForProcessingByAction:(BaseAction *)action phase:(BasePhase *)phase fromObject:(QCCProjectEssence *)object {
//    NSString *file = [object.path stringByAppendingString:@".tar"];
//    QCCProjectFile *artifactFile = [[QCCProjectFile alloc] initWithDictionary:@{QCCProjectSourcePathKey : file} identifier:nil];
//    artifactFile.parent = [self temeroryDirectoryGroup];
//    return artifactFile;
    return nil;
}

- (NSArray<NSString *> * __nonnull)artifactPrefixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[@"-f"];
}

- (NSArray<NSString *> * __nonnull)artifactPostfixesForProcessingByAction:(BaseAction * __nonnull)action phase:(BasePhase * __nonnull)phase UTTypeString:(NSString *__nonnull)UTTypeString {
    return @[];
}

-(BOOL)shouldReverseObjectAndArtifactSectionByAction:(BaseAction *)action phase:(BasePhase *)phase forObject:(QCCProjectEssence *)object {
    return YES;
}


@end
