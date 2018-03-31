//
//  QCCProjectProcessor+Launcher.m
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCProjectProcessor+Launcher.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>
#import "QCCError.h"
#import "Qapular-Swift.h"
#import "QCCDocumentController.h"

typedef void (^QCCProcessDocumentMaskEnumerateBlock)(QCCProcessDocumentFlag flag, NSUInteger idx, BOOL * _Nonnull stop);

@implementation QCCProjectProcessor (Launcher)

#pragma mark - QCCProcessDocumentInterfaceProtocol
- (BOOL) processDocument:(QCCProcessDocumentMask) processMask completionBlock:(QCCProcessDocumentBlock) globalCompletionBlock {
    
    [self.projectDocument saveDocument:self];
    
    if (self.processingDocumentMask != QCCProcessDocumentMaskNone && processMask != QCCProcessDocumentMaskStop) {
        return NO;
    }
    
    // Do not clear if it stop flag
    if (processMask != QCCProcessDocumentMaskStop) {
        [self clearReport];
    }else {
            if (self.globalProcessingCompletionBlock)
                self.globalProcessingCompletionBlock(processMask, [QCCError errorForCode:QCCErrorCodeActionTerminated]);
    }
    
    self.globalProcessingCompletionBlock = globalCompletionBlock;

    self.processingDocumentMask = processMask;
    
    if (![self deploymentSchema]) {
        if (self.globalProcessingCompletionBlock)
            self.globalProcessingCompletionBlock(processMask, [QCCError errorForCode:QCCErrorCodeTargetCanNotSupport]);
        
        self.processingDocumentMask = QCCProcessDocumentMaskNone;
        return NO;
    }
    
    if (processMask & QCCProcessDocumentFlagBuild || processMask & QCCProcessDocumentFlagUploadOnTarget) {
        for (NSString *packageIdentefier in [[self deploymentDependencyPackageIdentefiers] allObjects]) {
            QCCPackage *package = self.documentController.applicationTargetManager.packages[packageIdentefier];
            if (![package isInstalled]){
                if (self.globalProcessingCompletionBlock)
                    self.globalProcessingCompletionBlock(processMask, [QCCError errorForCode:QCCErrorCodeNeedInstallPackage]);
                
                self.processingDocumentMask = QCCProcessDocumentMaskNone;
                return NO;
            }
        }
    }
    
    if (processMask & QCCProcessDocumentFlagUploadOnTarget) {
        NSArray *targetPorts = [self.documentController.applicationTargetManager.attachedTargets[QCCTargetManagerKnownTargetsKey] allKeys];
        if (![targetPorts containsObject:self.selectedBSDPortName] || !self.selectedBSDPortName) {
            if (self.globalProcessingCompletionBlock)
                self.globalProcessingCompletionBlock(processMask, [QCCError errorForCode:QCCErrorCodeTargetDinNotSelected]);
            
            self.processingDocumentMask = QCCProcessDocumentMaskNone;
            return NO;
        }
    }
    
    __block BOOL flagSupportedBySchema = YES;
    NSArray <NSString *> *  availableActionKeys = [[self deploymentSchema] availableActionKeys];
    [QCCProjectProcessor enumerateMask:self.processingDocumentMask usingBlock:^(QCCProcessDocumentFlag flag, NSUInteger idx, BOOL * _Nonnull stop) {
        if (flag == QCCProcessDocumentMaskStop)
            return;
        
        if (![availableActionKeys containsObject:[QCCProjectProcessor schemaStringForProcessDocumentFlag:flag]]) {
            *stop = YES;
            if (self.globalProcessingCompletionBlock)
                self.globalProcessingCompletionBlock(self.processingDocumentMask, [QCCError errorForCode:QCCErrorCodeTargetCanNotSupport]);
            flagSupportedBySchema = NO;
        }
        
    }];

    if (!flagSupportedBySchema) {
        self.processingDocumentMask = QCCProcessDocumentMaskNone;
        return NO;
    }
    return [self launchProcessingFromFlag:QCCProcessDocumentFlagNone];
}

// Looking for next step in processing queue
- (BOOL) launchProcessingFromFlag:(QCCProcessDocumentFlag) startFlag {
    __block BOOL flagLaunched = NO;
    
    [QCCProjectProcessor enumerateMask:self.processingDocumentMask
                              fromFlag:startFlag
                            usingBlock:^(QCCProcessDocumentFlag flag, NSUInteger idx, BOOL * _Nonnull stop) {
                                dispatch_async(_processor_queue, ^{
                                    [self launchProcessStepForFlag:flag];
                                    
                                });
                                
                                flagLaunched = YES;
                                *stop = YES;
                            }];
    if (!flagLaunched) {
        self.processingDocumentMask = QCCProcessDocumentMaskNone;
    }
    
    return flagLaunched;
}

- (void) launchProcessStepForFlag:(QCCProcessDocumentFlag) flag {
    if (flag == QCCProcessDocumentMaskStop) {
        [self stopAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.globalProcessingCompletionBlock)
                self.globalProcessingCompletionBlock(QCCProcessDocumentMaskStop, nil);
        });
        
        [self launchProcessingFromFlag:flag];
        return;
    }
    
    if (flag == QCCProcessDocumentFlagUploadOnTarget) {
        [self.documentController.applicationTargetManager consoleWithBSDName:self.selectedBSDPortName pause:YES];
    }
    
    dispatch_async(_processor_queue, ^{
        NSString *actionKey = [QCCProjectProcessor schemaStringForProcessDocumentFlag:flag];
        NSString *identifier = [[self deploymentSchema] actionIdentifierForActionKey:actionKey];
        [self doAction:identifier type:[QCCProjectProcessor actionTypeForProcessDocumentFlag:flag]];
    });


}

#pragma mark - Action helper

- (void (^ _Nonnull)(BaseAction * _Nonnull, NSProgress * _Nonnull, NSError * _Nullable)) actionProgressClosure {
    return ^(BaseAction * action , NSProgress *  progress, NSError *  error) {
        if (progress.totalUnitCount == progress.completedUnitCount || error) {
            
            QCCProcessDocumentMask mask = [QCCProjectProcessor processDocumentMaskForActionType:action.type];
            QCCProcessDocumentFlag flag = [QCCProjectProcessor processDocumentFlagForActionType:action.type];
            
            self.globalProcessingCompletionBlock(mask, error);
            [self launchProcessingFromFlag:flag];
        }
    };
}

- (void (^ _Nonnull)(BaseAction * _Nonnull, BasePhase * _Nonnull, NSDictionary<NSString *, NSString *> * _Nonnull)) actionReportClosure {
    return ^(BaseAction * action, BasePhase * phase, NSDictionary<NSString *, NSString *> * report) {
        [self printReport:report];
    };
}


#pragma mark - Helper
+ (void) enumerateMask:(QCCProcessDocumentMask) mask fromFlag:(QCCProcessDocumentFlag) startFlag usingBlock:(QCCProcessDocumentMaskEnumerateBlock) block {
    [self enumerateMask:mask usingBlock:^(QCCProcessDocumentFlag flag, NSUInteger idx, BOOL * _Nonnull stop) {
        if (flag > startFlag) {
            if (block)
                block(flag, idx, stop);
        }
    }];
}

+ (void) enumerateMask:(QCCProcessDocumentMask) mask usingBlock:(QCCProcessDocumentMaskEnumerateBlock) block {
    
    for (NSUInteger flagIndex = QCCProcessDocumentFlagNone; pow(flagIndex, 2) < QCCProcessDocumentFlagFlashTarget; flagIndex ++) {
        __block BOOL stop = NO;
        
        QCCProcessDocumentFlag flag = (1 << flagIndex);
        if(block && mask & flag) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(flag, flagIndex, &stop);
            });
        }
        if (stop)
            break;
    }
}

+ (QCCProcessDocumentFlag) processDocumentFlagForActionType:(QCCActionType) actionType {
    switch (actionType) {
        case QCCActionTypeClear:
            return QCCProcessDocumentFlagClean;
            
        case QCCActionTypeCompile:
            return QCCProcessDocumentFlagBuild;
            
        case QCCActionTypeUpload:
            return QCCProcessDocumentFlagUploadOnTarget;
            
        default:
            return QCCProcessDocumentFlagNone;
            break;
    }
}

+ (QCCProcessDocumentMask) processDocumentMaskForActionType:(QCCActionType) actionType {
    switch (actionType) {
        case QCCActionTypeClear:
            return QCCProcessDocumentMaskClean;
            
        case QCCActionTypeCompile:
            return QCCProcessDocumentMaskBuild;
            
        case QCCActionTypeUpload:
            return QCCProcessDocumentMaskUploadOnTarget;
            
        default:
            return QCCProcessDocumentMaskNone;
            break;
    }
}


@end
