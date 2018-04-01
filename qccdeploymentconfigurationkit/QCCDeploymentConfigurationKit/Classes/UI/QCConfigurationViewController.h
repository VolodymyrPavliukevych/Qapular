//
//  QCConfigurationViewController.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCDeploymentConfigurationProvider.h"



@interface QCConfigurationViewController : NSViewController

@property (weak, nonatomic) IBOutlet    id<QCCDeploymentConfigurationProvider> deploymentConfigurationProvider;

+ (instancetype) default;

@end
