//
//  QCCProjectDocument.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseProjectDocument.h"
#import "QCCSourceTreeController.h"
#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>

@class QCCProjectProcessor;

@interface QCCProjectDocument : QCCBaseProjectDocument <QCCSourcetreeControllerDelegate, QCCDeploymentConfigurationProvider>

@property (nonatomic, readonly) QCCProjectProcessor *processor;

- (QCCProjectConfigurationContainer *) projectConfigurationContainer;
- (NSSet *) sourcePathSet;

- (void) selectAttachedPort:(NSString *) port;
- (void) selectDeploymentConfigurationContainerIdentifier:(NSString *) identifier;

@end
