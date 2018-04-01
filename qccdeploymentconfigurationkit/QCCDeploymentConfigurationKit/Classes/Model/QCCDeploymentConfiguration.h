//
//  QCCDeploymentConfiguration.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const QCCBaseConfigurationElementTypeKey;

extern NSString *const QCCBaseConfigurationElementKey;
extern NSString *const QCConfigurationContainerKey;

extern NSString *const QCCBaseConfigurationElementNameKey;
extern NSString *const QCCBaseConfigurationElementChildrenKey;

extern NSString *const QCCProjectConfigurationContainerKey;

extern NSString *const QCCBuildConfigurationUTIStringKey;

extern NSString *const QCCDeploymentConfigurationContainerKey;
extern NSString *const QCCDeploymentConfigurationContainerIdentifierKey;

extern NSString *const QCCBoardConfigurationContainerKey;
extern NSString *const QCCBoardConfigurationIdentifierKey;

extern NSString *const QCConfigurationPropertyKey;
extern NSString *const QCConfigurationPropertyKeyKey;
extern NSString *const QCConfigurationPropertyKeyLocalizationKey;
extern NSString *const QCConfigurationPropertyValueKey;
extern NSString *const QCConfigurationPropertyActionKeyKey;
extern NSString *const QCConfigurationPropertyTypeKey;
extern NSString *const QCConfigurationPropertyIsComplicatedValueKey;

@class QCCProjectConfigurationContainer;
@class QCCBoardConfigurationContainer;
@class QCCBaseConfigurationElement;
@class QCConfigurationContainer;
@class QCConfigurationProperty;
@protocol QCCMutableCollectionDelegate;
@protocol QCCDeploymentConfigurationLocalization;
@protocol QCCDeploymentConfigurationDataSource;

@interface QCCDeploymentConfiguration : NSObject

@property (nonatomic, weak) id<QCCDeploymentConfigurationDataSource> dataSource;
@property (nonatomic, weak) id<QCCDeploymentConfigurationLocalization> localizationDataSource;
@property (nonatomic, weak) id <QCCMutableCollectionDelegate> delegate;

- (instancetype)initWithDictionary:(NSDictionary *) dict;

- (QCCProjectConfigurationContainer *) projectConfigurationContainer;
- (NSDictionary *) targetItems;
- (NSDictionary *) serialize;
- (BOOL) addElement:(QCCBaseConfigurationElement *) element toContainer:(QCConfigurationContainer *) container;
- (QCCBoardConfigurationContainer *) boardConfigurationForIdentifier:(NSString *) identifier;

@end
