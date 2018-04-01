//
//  QCCDeploymentConfigurationProvider.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCCDeploymentConfiguration;

@protocol QCCDeploymentConfigurationProvider <NSObject>

@required
- (QCCDeploymentConfiguration *) deploymentConfiguration;

@end
