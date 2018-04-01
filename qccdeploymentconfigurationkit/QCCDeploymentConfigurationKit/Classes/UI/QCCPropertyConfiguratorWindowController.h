//
//  QCCPropertyConfiguratorWindowController.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCConfigurationProperty.h"

@class QCCPropertyConfiguratorWindowController;

@protocol QCCPropertyConfiguratorDataSource <NSObject>

- (nonnull NSDictionary <NSString *, NSString *>*) keyList;
- (nonnull NSDictionary <NSString *, NSString *>*) actionList;
- (nonnull NSDictionary <NSString *, NSString *>*) UTTypeList;

@end

typedef void (^PropertyConfiguratorCompletionBlock)(QCCPropertyConfiguratorWindowController * _Nonnull configuratorWindowController,
                                                    NSString * _Nullable propertyValue,
                                                    NSString * _Nullable propertyKey,
                                                    NSSet    * _Nullable propertyActionList,
                                                    NSString * _Nullable propertyUTTypeString,
                                                    BOOL isComplicatedValue,
                                                    PropertyType propertyType);

@interface QCCPropertyConfiguratorWindowController : NSWindowController

@property (nullable, nonatomic, weak) id <QCCPropertyConfiguratorDataSource> dataSource;

- (nonnull instancetype) initWithDataSource:(nonnull id <QCCPropertyConfiguratorDataSource>) dataSource completion:(nonnull PropertyConfiguratorCompletionBlock) resultBlock;

@end
