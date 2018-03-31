//
//  QCCProjectProcessor.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//


#import "QCCProjectProcessor.h"
#import "QCCProjectProcessor+Storage.h"
#import "QCCDocumentController.h"
#import "QCCProjectDocument.h"
#import "NSObject+Cast.h"
#import "QCCError.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>
#import <ActionKit/ActionKit-Swift.h>


@interface QCCProjectProcessor () {
    
    QCCProjectDocument      *_projectDocument;
    NSURL                   *_buildTemporaryFolderURL;
    QCCProjectGroup         *_temeroryDirectoryGroup;

}

- (QCCProjectDocument *) projectDocument;

@end

@implementation QCCProjectProcessor


static const char *QCCProjectProcessorQueueLabel = "QCCProjectProcessorQueue";

- (instancetype) initForProjectDocument:(QCCProjectDocument *) document documentController:(QCCDocumentController *) documentController {

    if (!document || !documentController)
        return nil;
    
    self = [super init];
    
    if (self) {
        _documentController = documentController;
        _projectDocument = document;
        
        dispatch_queue_attr_t processor_queueAttr = dispatch_queue_attr_make_with_qos_class (DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, -1);
        _processor_queue = dispatch_queue_create(QCCProjectProcessorQueueLabel, processor_queueAttr);
        _actionList = [NSMutableDictionary new];
    }
    
    return self;
    
}


#pragma mark - Enviroment
- (NSString *) projectName {
    return [[_projectDocument.fileURL lastPathComponent] stringByDeletingPathExtension];
}


- (NSSet *) projectSourceSet {
    NSSet *projectSourceSet = [NSSet setWithArray:_projectDocument.sourceTreeContentArray];
    return projectSourceSet;
}

- (QCCProjectDocument *) projectDocument {
    return _projectDocument;
}

- (NSURL *) buildTemporaryFolderURL {
    
    if(_buildTemporaryFolderURL)
        return _buildTemporaryFolderURL;
    
    NSString *storage = [QCCProjectProcessor storageFolder];
    NSString *projectFolderPath = [storage stringByAppendingPathComponent:[self projectName]];
    NSString *temporaryFolderPath = [projectFolderPath stringByAppendingPathComponent:self.selectedDeploymentConfigurationContainerIdentifier];
    temporaryFolderPath = [temporaryFolderPath stringByAppendingString:@"/"];
    _buildTemporaryFolderURL = [NSURL URLWithString:temporaryFolderPath];
    
    
    NSError *error;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:_buildTemporaryFolderURL.path
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    
    if (result && !error)
        return _buildTemporaryFolderURL;
    
    NSLog(@"Error: %@", error);
    return nil;
}

- (QCCProjectGroup *) temeroryDirectoryGroup {
    if (!_temeroryDirectoryGroup) {
        _temeroryDirectoryGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey:[[self buildTemporaryFolderURL] lastPathComponent], QCCProjectSourceRootFileKey : @(YES)}
                                                                   identifier:nil
                                                                   projectURL:[[self buildTemporaryFolderURL] URLByDeletingLastPathComponent]];
    }
    
    return _temeroryDirectoryGroup;
}

// temeroryGroup fabric
- (QCCProjectGroup *) temeroryGroup {
    QCCProjectGroup *temeroryGroup = [[QCCProjectGroup alloc] initWithDictionary:@{QCCProjectSourcePathKey:[[self buildTemporaryFolderURL] lastPathComponent], QCCProjectSourceRootFileKey : @(YES)}
                                                               identifier:nil
                                                               projectURL:[[self buildTemporaryFolderURL] URLByDeletingLastPathComponent]];

    return temeroryGroup;
}

- (NSArray <QCConfigurationProperty *> *) deploymentPropertyList {
    NSMutableArray *array = [NSMutableArray new];
    
    for (QCCBaseConfigurationElement *element in [[_projectDocument projectConfigurationContainer] children]) {
        if ([element isKindOfClass:[QCConfigurationProperty class]]) {
            [array addObject:element];
        }
    }
    
    for (QCCBaseConfigurationElement *element in [[self currentDeploymentConfigurationContainer] children]) {
        if ([element isKindOfClass:[QCConfigurationProperty class]]) {
            [array addObject:element];
        }
    }
    
    return array;
}

- (QCCDeploymentConfigurationContainer *) currentDeploymentConfigurationContainer {
    NSDictionary *dict = [[_projectDocument projectConfigurationContainer] deployemntConfigurationContainers];
    if ([[dict allKeys] count] == 0)
        return nil;

    if (!self.selectedDeploymentConfigurationContainerIdentifier || !dict[self.selectedDeploymentConfigurationContainerIdentifier])
        _selectedDeploymentConfigurationContainerIdentifier = [[dict allKeys] firstObject];
    
    return dict[self.selectedDeploymentConfigurationContainerIdentifier];
}

- (QCCTarget *) deploymentTarget {
    
    QCCBoardConfigurationContainer * boardContainer = [[self currentDeploymentConfigurationContainer] boardConfigurationContainer];
    NSString *targetIdentefier = boardContainer.identifier;

    if (!targetIdentefier)
        return nil;
    
    QCCTarget *deploymentTarget = _documentController.applicationTargetManager.targets[targetIdentefier];
    return deploymentTarget;
}

- (QCCSchema *) deploymentSchema {
    return [self deploymentTarget].schema;
}

// The same method with QCCSchema 
- (NSSet <NSString *> *) deploymentDependencyPackageIdentefiers {
    
    __block NSMutableSet *packagesIdentefiers = [NSMutableSet new];

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        packagesIdentefiers = [NSMutableSet new];
        QCCSchema *schema = [self deploymentSchema];

        // Shared Property
        [packagesIdentefiers addObjectsFromArray:[self packageIdentefiersFromPropertyList:[schema sharedPropertyList]]];
        
        for (NSString *actionKey in [schema availableActionKeys]) {
        
            NSArray *rawPhaseList = [schema phaseListForActionKey:actionKey];
            
            for (NSDictionary *rawPhase in rawPhaseList) {
                [packagesIdentefiers addObjectsFromArray:[self packageIdentefiersFromPropertyList:[schema propertyListForPhase:rawPhase]]];
                
                // Tools
                for (NSString *toolPath in [[schema processingToolsForPhase:rawPhase] allValues]) {
                    QCComplexURL *packageURL = [[QCComplexURL alloc] initWithString:toolPath packageManager:^QCCPackage * _Nullable(NSString * _Nonnull identifier) {
                        return _documentController.applicationTargetManager.packages[identifier];
                    }];
                    if (packageURL.packageIdentifier)
                        [packagesIdentefiers addObject:packageURL.packageIdentifier];
                }
            }
        }
    });
    
    return packagesIdentefiers;
}

- (NSArray *) packageIdentefiersFromPropertyList:(NSArray <NSDictionary <NSString *, id> *> *) propertyList {
    NSMutableArray *packagesIdentefiers = [NSMutableArray new];
    for (NSDictionary *rawProperty in propertyList) {
        QCCBaseConfigurationElement *element = [QCCDeploymentConfiguration elementFromDictionary:rawProperty];
        if ([element isKindOfClass:[QCConfigurationProperty class]]) {
            QCConfigurationProperty *property = (QCConfigurationProperty *) element;
            if (property.isComplicatedValue) {
                
                QCComplexURL *packageURL = [[QCComplexURL alloc] initWithString:property.value packageManager:^QCCPackage * _Nullable(NSString * _Nonnull identifier) {
                    return _documentController.applicationTargetManager.packages[identifier];
                }];
                if (packageURL.packageIdentifier)
                    [packagesIdentefiers addObject:packageURL.packageIdentifier];
            }
        }
    }
    return packagesIdentefiers;
}


- (nonnull NSArray <QCConfigurationProperty *> *) defaultPropertyList {

    static dispatch_once_t onceToken;
    static NSMutableArray <QCConfigurationProperty *> * list;
    
    dispatch_once(&onceToken, ^{
        list = [NSMutableArray new];
        
        for (NSDictionary *rawProperty in [[[[self projectDocument] deploymentConfiguration] defaultFrontPropertyList] allValues]) {
            QCCBaseConfigurationElement *element = [QCCDeploymentConfiguration elementFromDictionary:rawProperty];
            if ([element isKindOfClass:[QCConfigurationProperty class]]) {
                [list addObject:(QCConfigurationProperty *) element];
            }
        }
        
    });
    
    return list;
}

#pragma mark - Actions data bridge
+ (NSString *) schemaStringForProcessDocumentFlag:(QCCProcessDocumentFlag) flag {
    switch (flag) {
            
        case QCCProcessDocumentFlagNone:
            break;
            
        case QCCProcessDocumentFlagClean:
            return QCCSchemaActionClearKey;
            
        case QCCProcessDocumentFlagBuild:
            return QCCSchemaActionCompileKey;
            
        case QCCProcessDocumentFlagUploadOnTarget:
            return QCCSchemaActionUploadKey;
            
        case QCCProcessDocumentFlagRunOnTarget:
            return QCCSchemaActionRunKey;
            
        case QCCProcessDocumentFlagEraseTarget:
            break;
            
        case QCCProcessDocumentFlagFlashTarget:
            break;
            
        default:
            NSAssert(YES, @"Schema string is not ready for that QCCProcessDocumentFlag");
            return nil;
    }
    
    NSAssert(YES, @"Schema string is not ready for that QCCProcessDocumentFlag");
    return nil;
}

+ (QCCActionType) actionTypeForProcessDocumentFlag:(QCCProcessDocumentFlag) flag {
    
    switch (flag) {
            
        case QCCProcessDocumentFlagNone:
            break;
            
        case QCCProcessDocumentFlagClean:
            return QCCActionTypeClear;
            
        case QCCProcessDocumentFlagBuild:
            return QCCActionTypeCompile;
            
        case QCCProcessDocumentFlagUploadOnTarget:
            return QCCActionTypeUpload;
            
        case QCCProcessDocumentFlagRunOnTarget:
            return QCCActionTypeRun;
            
        case QCCProcessDocumentFlagEraseTarget:
            return QCCActionTypeErase;
            
        case QCCProcessDocumentFlagFlashTarget:
            break;
            
        default:
            NSAssert(YES, @"Action type is not ready for that QCCProcessDocumentFlag");
            return QCCActionTypeClear;
    }
    NSAssert(YES, @"Action type is not ready for that QCCProcessDocumentFlag");
    return QCCActionTypeClear;
}


@end
