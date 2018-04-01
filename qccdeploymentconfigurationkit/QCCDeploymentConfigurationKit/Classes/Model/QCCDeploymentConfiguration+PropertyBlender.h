//
//  QCCDeploymentConfiguration+PropertyBlender.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>

@class QCConfigurationProperty;

@interface QCCDeploymentConfiguration (PropertyBlender)

- (nonnull NSArray <NSString *> *) blandPropertyWithRaw:(nonnull NSArray<NSDictionary <NSString *, id > *> *) array;
- (nonnull NSArray <NSString *> *) blandProperty:(nonnull NSArray<QCConfigurationProperty *> *) array;

@end
