//
//  QCConfigurationProperty.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCBaseConfigurationElement.h"

typedef enum : NSUInteger {
    PropertyTypeFront,
    PropertyTypeBack
} PropertyType;

@interface QCConfigurationProperty : QCCBaseConfigurationElement

@property (nonnull, nonatomic, readonly) NSString        *UTIString;
@property (nonnull, nonatomic, readonly) NSString        *value;

@property (nonnull, nonatomic, readonly) NSString        *key;
@property (nonnull, nonatomic, readonly) NSString        *key_localization;
@property (nonnull, nonatomic, readonly) NSSet <NSString *> *actionKeys;

@property (nonatomic, readonly) PropertyType    type;
@property (nonatomic, readonly) BOOL            isComplicatedValue;

@property (nullable, nonatomic, weak) id<QCCDeploymentConfigurationLocalization> localizationDataSource;

- (BOOL) updateValue:(nonnull NSString *) value;

@end
