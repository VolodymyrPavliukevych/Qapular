//
//  QCCProjectConfigurationContainer.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationContainer.h"

@class QCCDeploymentConfigurationContainer;

@interface QCCProjectConfigurationContainer : QCConfigurationContainer
@property (nonatomic, readonly) NSArray<NSString *> * boardIdentifiers;

- (NSDictionary <NSString* , QCCDeploymentConfigurationContainer * >*) deployemntConfigurationContainers;
- (NSArray *) deployemntConfigurationIdentifiers;

@end
