//
//  QCConfigurationProperty.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationProperty.h"

@implementation QCConfigurationProperty
- (instancetype) initWithDictionary:(NSDictionary *) dict {
    self = [super initWithDictionary:dict];
    if (self) {
        
        _UTIString = dict[QCCBuildConfigurationUTIStringKey];
        _key = dict[QCConfigurationPropertyKeyKey];
        _value = dict[QCConfigurationPropertyValueKey];
        _actionKeys = [NSSet setWithArray:dict[QCConfigurationPropertyActionKeyKey]];
        _key_localization = dict[QCConfigurationPropertyKeyLocalizationKey];
        NSNumber *type = dict[QCConfigurationPropertyTypeKey];
        
        
        NSNumber *complicatedValue = dict[QCConfigurationPropertyIsComplicatedValueKey];
        _isComplicatedValue = (complicatedValue && [complicatedValue boolValue]);
        
        if (type)
            _type = [type unsignedIntegerValue];
        else
            _type = PropertyTypeBack;
        
    }
    
    return self;
}

- (BOOL) updateValue:(NSString *) value {
    if(!value)
        return NO;
    
    _value = value;
    return YES;
    
}

-(NSDictionary *)serialize {

    NSMutableDictionary *dict = [[super serialize] mutableCopy];
    dict[QCCBaseConfigurationElementTypeKey] = QCConfigurationPropertyKey;
    
    if (self.key)
        dict[QCConfigurationPropertyKeyKey] = self.key;
    
    if (self.actionKeys)
        dict[QCConfigurationPropertyActionKeyKey] = [self.actionKeys allObjects];
    
    if (self.value)
        dict[QCConfigurationPropertyValueKey] = self.value;
    
    if (self.UTIString)
        dict[QCCBuildConfigurationUTIStringKey] = self.UTIString;
    
    if (self.type)
        dict[QCConfigurationPropertyTypeKey] = @(self.type);
    
    if (self.key_localization)
        dict[QCConfigurationPropertyKeyLocalizationKey] = self.key_localization;
    
    dict[QCConfigurationPropertyIsComplicatedValueKey] = @(_isComplicatedValue);
    
    return dict;
}


@end
