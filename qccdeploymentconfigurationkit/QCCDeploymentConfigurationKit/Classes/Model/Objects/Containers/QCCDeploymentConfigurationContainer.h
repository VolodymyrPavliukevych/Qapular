//
//  QCCDeploymentConfigurationContainer.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationContainer.h"

@class QCCBoardConfigurationContainer;


@interface QCCDeploymentConfigurationContainer : QCConfigurationContainer

@property (nonnull, nonatomic, readonly) NSString *identifier;
@property (nonnull, nonatomic, readonly) NSString *boardIdentifier;

- (BOOL) replaceBoardConfiguration:(nonnull QCCBoardConfigurationContainer *) boardConfiguration;
- (nullable QCCBoardConfigurationContainer *) boardConfigurationContainer;

@end
