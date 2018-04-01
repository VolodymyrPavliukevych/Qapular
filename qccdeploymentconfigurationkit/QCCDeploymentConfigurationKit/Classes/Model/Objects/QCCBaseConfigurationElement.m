//
//  QCCBaseConfigurationElement.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright (c) 2014 Vladimir Pavliukevych. All rights reserved.
//

#import "QCCBaseConfigurationElement.h"

@implementation QCCBaseConfigurationElement


- (instancetype)initWithDictionary:(NSDictionary *) dict {

    self = [super init];
    if (self) {
        _name = dict[QCCBaseConfigurationElementNameKey];
    }
    return self;
}


- (NSDictionary *) serialize {
    NSDictionary *dict = @{QCCBaseConfigurationElementTypeKey : QCCBaseConfigurationElementKey,
                           QCCBaseConfigurationElementNameKey : (self.name ? self.name : @"no name")};
    
    return dict;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ %@ %p", NSStringFromClass([self class]), self.name, self];
}


@end
