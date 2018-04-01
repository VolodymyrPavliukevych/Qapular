//
//  QCCDeploymentConfiguration+Constructor.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfiguration.h"
#import "QCCDeploymentConfiguration+Constructor.h"

#import "QCCProjectConfigurationContainer.h"
#import "QCCDeploymentConfigurationContainer.h"
#import "QCCBoardConfigurationContainer.h"
#import "QCConfigurationProperty.h"


@implementation QCCDeploymentConfiguration (Constructor)

+ (QCCBaseConfigurationElement *) elementFromDictionary:(NSDictionary *) dict {
    
    NSString *typeKey = dict[QCCBaseConfigurationElementTypeKey];
    Class containerClass;
    
    if ([typeKey isEqualToString:QCCProjectConfigurationContainerKey])
        containerClass = [QCCProjectConfigurationContainer class];
    
    if ([typeKey isEqualToString:QCCDeploymentConfigurationContainerKey])
        containerClass = [QCCDeploymentConfigurationContainer class];
    
    if ([typeKey isEqualToString:QCCBoardConfigurationContainerKey])
        containerClass = [QCCBoardConfigurationContainer class];
    
    if ([typeKey isEqualToString:QCConfigurationPropertyKey])
        containerClass = [QCConfigurationProperty class];
    
    if (containerClass)
        return [[containerClass alloc] initWithDictionary:dict];
    
    return nil;
}

+ (QCConfigurationProperty *) stringPropertyForUTI:(NSString *) UTIString value:(NSString *) value key:(NSString *) key  action:(NSString *) actionKey type:(PropertyType) type {
    NSDictionary *dict = [self propertyForKey:key UTIString:UTIString value:value action:actionKey type:type];

    if (!dict)
        return nil;
    
    return (QCConfigurationProperty *) [[self class] elementFromDictionary:dict];
}

+ (NSDictionary *) propertyForKey:(NSString *) key UTIString:(NSString *) UTIString value:(id) value action:(NSString *) actionKey type:(PropertyType) type {
    if (!value || !key || !UTIString || !actionKey)
        return nil;
    
    NSDictionary *dict = @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                           QCConfigurationPropertyKeyKey: key,
                           QCConfigurationPropertyValueKey: value,
                           QCCBuildConfigurationUTIStringKey: UTIString,
                           QCConfigurationPropertyActionKeyKey : actionKey,
                           QCConfigurationPropertyTypeKey : @(type)
                           };
    
    return dict;
}

+ (QCCDeploymentConfigurationContainer *) deploymentConfigurationWithName:(NSString *) name {
    return (QCCDeploymentConfigurationContainer *)[self elementFromDictionary:[self deploymentConfigurationDictionaryWithName:name]];
}

+ (NSDictionary *) deploymentConfigurationDictionaryWithName:(NSString *) name {
    
    NSDictionary *dict = @{QCCBaseConfigurationElementTypeKey : QCCDeploymentConfigurationContainerKey,
                           QCCBaseConfigurationElementNameKey : name,
                           QCCDeploymentConfigurationContainerIdentifierKey : [[NSUUID UUID] UUIDString],
                           QCCBaseConfigurationElementChildrenKey: @[]};
    
    return dict;
}


@end
