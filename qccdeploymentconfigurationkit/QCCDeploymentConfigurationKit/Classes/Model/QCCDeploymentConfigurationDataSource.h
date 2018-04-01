//
//  QCCDeploymentConfigurationDataSource.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol QCCDeploymentConfigurationLocalization <NSObject>

- (nullable NSString *) localizationStringForKey:(nonnull NSString *) key;

@end

@protocol QCCDeploymentConfigurationDataSource <NSObject>

@required

// Target name, Target identifier
- (nonnull NSDictionary <NSString *, NSString * > *) targetItems;

// Available action keys and localysed strings
- (nonnull NSDictionary <NSString *, NSString * > *) actionKeyList;

@end


