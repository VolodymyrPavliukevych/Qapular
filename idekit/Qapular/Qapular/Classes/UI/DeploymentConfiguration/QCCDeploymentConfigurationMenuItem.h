//
//  QCCDeploymentConfigurationMenuItem.h
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCDeploymentConfigurationMenuItem : NSMenuItem

@property (nonnull, nonatomic, readonly) NSString *identifier;

- (nonnull instancetype) initWithTitle:(nonnull NSString *) aString identifier:(nonnull NSString *) identifier;

@end
