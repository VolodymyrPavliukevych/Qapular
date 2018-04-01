//
//  QCCBaseConfigurationElement.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCCDeploymentConfiguration.h"

@interface QCCBaseConfigurationElement : NSObject

@property (nonatomic, readonly) BOOL        isExpandable;
@property (nonatomic, readonly) BOOL        isContainer;
@property (nonatomic, readonly) NSString    *name;


- (instancetype)initWithDictionary:(NSDictionary *) dict;

- (NSDictionary *) serialize;

@end
