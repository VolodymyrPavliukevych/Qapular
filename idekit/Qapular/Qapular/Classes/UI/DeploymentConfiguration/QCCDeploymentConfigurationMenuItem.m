//
//  QCCDeploymentConfigurationMenuItem.m
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfigurationMenuItem.h"

@implementation QCCDeploymentConfigurationMenuItem
-(nonnull instancetype) initWithTitle:(nonnull NSString *) aString identifier:(nonnull NSString *) identifier {

    self = [super initWithTitle:aString action:nil keyEquivalent:@""];
    if (self) {
        _identifier = identifier;
    }
    return self;
    
}
@end
