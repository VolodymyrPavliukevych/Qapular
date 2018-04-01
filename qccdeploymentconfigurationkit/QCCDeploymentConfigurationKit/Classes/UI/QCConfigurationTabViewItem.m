//
//  QCConfigurationTabViewItem.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationTabViewItem.h"
#import "QCConfigurationViewController.h"

@interface QCConfigurationTabViewItem () {
    QCConfigurationViewController *_configurationViewController;
}

@end

@implementation QCConfigurationTabViewItem

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _configurationViewController = [QCConfigurationViewController default];
        [self setViewController:_configurationViewController];
        
    }
    return self;

    
}

-(void)setDeploymentConfigurationProvider:(id)deploymentConfigurationProvider {

    _deploymentConfigurationProvider = deploymentConfigurationProvider;
    [_configurationViewController setDeploymentConfigurationProvider:_deploymentConfigurationProvider];
    
}


@end
