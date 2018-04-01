//
//  QCCDeploymentConfiguration+QCCPropertyConfiguratorDataSource.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>


@interface QCCDeploymentConfiguration (QCCPropertyConfiguratorDataSource) <QCCPropertyConfiguratorDataSource>
- (nonnull NSDictionary <NSString *, NSDictionary <NSString *, id> * > *) defaultFrontPropertyList;
@end
