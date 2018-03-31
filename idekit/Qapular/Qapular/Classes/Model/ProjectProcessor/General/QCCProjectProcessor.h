//
//  QCCProjectProcessor.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ActionKit/ActionKit.h>
#import <ActionKit/ActionKit-Swift.h>

#import <QCCProjectEssenceKit/QCCProjectGroup.h>

#import "QCCProcessDocumentProtocol.h"
#import "QCCProjectEnvironmentSource.h"
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>
#import "QCCDocumentController.h"

@class QCCProjectDocument;

@class QCCSchema;
@class QCCTarget;

@interface QCCProjectProcessor : NSObject {
                                                
    NSString                *_selectedBSDPortName;
    NSString                *_selectedDeploymentConfigurationContainerIdentifier;
    dispatch_queue_t        _processor_queue;
}

@property (nullable, nonatomic, copy) QCCProcessDocumentBlock globalProcessingCompletionBlock;
@property (atomic) QCCProcessDocumentMask  processingDocumentMask;



@property (nonatomic, readonly) NSString    * _Nullable selectedBSDPortName;
@property (nonatomic, readonly) NSString    * _Nullable selectedDeploymentConfigurationContainerIdentifier;
@property (nonatomic, readonly) QCCDocumentController * _Nonnull documentController;

@property (nonatomic) id <QCCProcessReportProtocol> _Nullable processReportDelegate;
@property (nonatomic, readonly) NSMutableDictionary  <QCCAction *, NSString *> * _Nonnull actionList;

- (nonnull instancetype) initForProjectDocument:(nonnull QCCProjectDocument *) document documentController:(nonnull QCCDocumentController *) documentController;
- (nonnull QCCProjectDocument *) projectDocument;

- (nonnull NSURL *) buildTemporaryFolderURL;
- (nonnull QCCProjectGroup *) temeroryDirectoryGroup;

// temeroryGroup fabric,
- (nonnull QCCProjectGroup *) temeroryGroup;
- (nonnull NSArray <QCConfigurationProperty *> *) deploymentPropertyList;
- (nonnull QCCTarget *) deploymentTarget;
- (nonnull QCCSchema *) deploymentSchema;
- (nonnull NSSet <NSString *> *) deploymentDependencyPackageIdentefiers;

- (nonnull NSArray <QCConfigurationProperty *> *) defaultPropertyList;


#pragma mark - Actions data bridge
+ (nullable NSString *) schemaStringForProcessDocumentFlag:(QCCProcessDocumentFlag) flag;
+ (QCCActionType) actionTypeForProcessDocumentFlag:(QCCProcessDocumentFlag) flag;

@end
