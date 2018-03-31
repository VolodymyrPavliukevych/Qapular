//
//  QCCProjectProcessor+Project.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCProjectProcessor.h"

@interface QCCProjectProcessor (Project)
- (void) selectAttachedPort:(NSString *) port;
- (void) selectDeploymentConfigurationContainerIdentifier:(NSString *) identifier;
@end
