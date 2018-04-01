//
//  QCCDeploymentConfiguration.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfiguration.h"

#import "QCCProjectConfigurationContainer.h"
#import "QCConfigurationProperty.h"
#import "QCCDeploymentConfigurationContainer.h"
#import "QCCBoardConfigurationContainer.h"

#import "QCCDeploymentConfiguration+Constructor.h"
#import "QCCDeploymentConfigurationDataSource.h"

NSString *const QCCBaseConfigurationElementTypeKey                   = @"QCCBaseConfigurationElementType";

NSString *const QCCBaseConfigurationElementKey                       = @"QCCBaseConfigurationElement";
NSString *const QCConfigurationContainerKey                          = @"QCConfigurationContainer";

NSString *const QCCBaseConfigurationElementNameKey                   = @"QCCBaseConfigurationElementName";
NSString *const QCCBaseConfigurationElementChildrenKey               = @"QCCBaseConfigurationElementChildren";

NSString *const QCCProjectConfigurationContainerKey                  = @"QCCProjectConfigurationContainer";

NSString *const QCCBuildConfigurationUTIStringKey                    = @"QCCBuildConfigurationUTIString";

NSString *const QCCDeploymentConfigurationContainerKey               = @"QCCDeploymentConfigurationContainer";
NSString *const QCCDeploymentConfigurationContainerIdentifierKey     = @"QCCDeploymentConfigurationContainerIdentifier";

NSString *const QCCBoardConfigurationContainerKey                    = @"QCCBoardConfigurationContainer";
NSString *const QCCBoardConfigurationIdentifierKey                   = @"QCCBoardConfigurationIdentifier";

NSString *const QCConfigurationPropertyKey                           = @"QCConfigurationProperty";
NSString *const QCConfigurationPropertyKeyKey                        = @"QCConfigurationPropertyKey";
NSString *const QCConfigurationPropertyKeyLocalizationKey            = @"QCConfigurationPropertyKeyLocalization";
NSString *const QCConfigurationPropertyValueKey                      = @"QCConfigurationPropertyValue";
NSString *const QCConfigurationPropertyActionKeyKey                  = @"QCConfigurationPropertyActionKey";
NSString *const QCConfigurationPropertyTypeKey                       = @"QCConfigurationPropertyType";
NSString *const QCConfigurationPropertyIsComplicatedValueKey        = @"QCConfigurationPropertyIsComplicatedValue";


@interface QCCDeploymentConfiguration () <QCCMutableCollectionDelegate> {
    QCCProjectConfigurationContainer        *_projectConfigurationContainer;
    NSDictionary                            *_dictionary;
}

@end

@implementation QCCDeploymentConfiguration

- (instancetype)initWithDictionary:(NSDictionary *) dict {
    
    self = [super init];
    
    if (self) {
        _dictionary = [dict copy];
    }
    
    return self;
}
- (NSDictionary *) serialize {
    return [[self projectConfigurationContainer] serialize];
}

#pragma mark - Element manipulation


- (BOOL) addElement:(QCCBaseConfigurationElement *) element toContainer:(QCConfigurationContainer *) container {
    return [container addChild:element];
}

#pragma mark - Provider
- (NSDictionary *) targetItems {
    return [[self.dataSource targetItems] copy];
}

- (QCCProjectConfigurationContainer *) projectConfigurationContainer {
    if (_projectConfigurationContainer)
        return _projectConfigurationContainer;
    
    if (!_dictionary)
        _dictionary = @{QCCBaseConfigurationElementTypeKey : QCCProjectConfigurationContainerKey,
                        QCCBaseConfigurationElementNameKey : NSLocalizedString(@"Project configuration", @"QCCDeploymentConfiguration class")};
    
    if (![_dictionary[QCCBaseConfigurationElementTypeKey] isEqualToString:QCCProjectConfigurationContainerKey])
        return nil;
    
    QCCBaseConfigurationElement *baseConfigurationElement = [QCCDeploymentConfiguration elementFromDictionary:_dictionary];
    
    if ([baseConfigurationElement isKindOfClass:[QCCProjectConfigurationContainer class]])
        _projectConfigurationContainer = (QCCProjectConfigurationContainer *) baseConfigurationElement;
    
    _projectConfigurationContainer.delegate = self;
    return _projectConfigurationContainer;
}

- (QCCBoardConfigurationContainer *) boardConfigurationForIdentifier:(NSString *) identifier {
    NSDictionary *boardDict = [self boardDictionaryConfigurationForIdentifier:identifier];
    QCCBaseConfigurationElement *element = [QCCDeploymentConfiguration elementFromDictionary:boardDict];
    
    if ([element isKindOfClass:[QCCBoardConfigurationContainer class]])
        return (QCCBoardConfigurationContainer * ) element;
    
    return nil;
}

- (NSDictionary *) boardDictionaryConfigurationForIdentifier:(NSString *) identifier {
    
    if (!identifier)
        return nil;
    
    NSString *targetName = [self.dataSource targetItems][identifier];
 
    if (!targetName)
        return nil;
    
    NSDictionary *dict = @{QCCBaseConfigurationElementTypeKey : QCCBoardConfigurationContainerKey,
                           QCCBaseConfigurationElementNameKey : targetName,
                           QCCBoardConfigurationIdentifierKey : identifier,
                           QCCBaseConfigurationElementChildrenKey: @[] };
    
    return dict;
}

-(void)addedObject {
    if ([_delegate respondsToSelector:@selector(addedObject)]) {
        [_delegate addedObject];
    }
}

-(void)removedObject {
    if ([_delegate respondsToSelector:@selector(removedObject)]) {
        [_delegate removedObject];
    }
}

@end

