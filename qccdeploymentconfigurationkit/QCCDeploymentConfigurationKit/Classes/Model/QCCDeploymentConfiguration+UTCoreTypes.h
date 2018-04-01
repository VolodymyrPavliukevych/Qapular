//
//  QCCDeploymentConfiguration+UTCoreTypes.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <QCCDeploymentConfigurationKit/QCCDeploymentConfigurationKit.h>

@interface QCCDeploymentConfiguration (UTCoreTypes)

+ (NSDictionary *) UTIPropertyDictionary;
+ (NSString *) identifierForUTType:(CFStringRef) type;

@end
