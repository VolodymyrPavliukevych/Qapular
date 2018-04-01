//
//  QCConfigurationTabViewItem.h
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCCDeploymentConfigurationProvider.h"


@interface QCConfigurationTabViewItem : NSTabViewItem

@property (weak, nonatomic) IBOutlet    id<QCCDeploymentConfigurationProvider>  deploymentConfigurationProvider;

@end
