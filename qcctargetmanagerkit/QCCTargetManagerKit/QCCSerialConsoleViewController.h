//
//  QCCSerialConsoleViewController.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavlyukevich on 5/22/16.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class QCCPortManager;

@interface QCCSerialConsoleViewController : NSViewController

@property (nullable, nonatomic, readonly, strong) QCCPortManager *portManager;

+ (nullable instancetype) consoleWithPortManager:(nonnull QCCPortManager *) portManager;

@end
