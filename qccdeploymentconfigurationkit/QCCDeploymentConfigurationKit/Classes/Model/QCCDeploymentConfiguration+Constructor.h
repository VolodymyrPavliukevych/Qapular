//
//  QCCDeploymentConfiguration+Constructor.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfiguration.h"
#import "QCConfigurationProperty.h"

@class QCCDeploymentConfigurationContainer;
@class QCCBaseConfigurationElement;
@class QCConfigurationProperty;

@interface QCCDeploymentConfiguration (Constructor)

+ (QCCBaseConfigurationElement *) elementFromDictionary:(NSDictionary <NSString *, id>*) dict;
+ (QCConfigurationProperty *) stringPropertyForUTI:(NSString *) UTIString value:(NSString *) value key:(NSString *) key action:(NSString *) actionKey type:(PropertyType) type;
+ (NSDictionary *) propertyForKey:(NSString *) key UTIString:(NSString *) UTIString value:(id) value action:(NSString *) actionKey type:(PropertyType) type;
+ (QCCDeploymentConfigurationContainer *) deploymentConfigurationWithName:(NSString *) name;

@end
