//
//  QCCProjectProcessor+Project.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectProcessor+Project.h"

@implementation QCCProjectProcessor (Project)

- (void) selectAttachedPort:(NSString *) port {
    _selectedBSDPortName = port;
}

- (void) selectDeploymentConfigurationContainerIdentifier:(NSString *) identifier {
    _selectedDeploymentConfigurationContainerIdentifier = identifier;
}

@end
