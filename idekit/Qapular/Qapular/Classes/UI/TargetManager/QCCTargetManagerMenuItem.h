//
//  QCCTargetManagerMenuItem.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCCTargetManagerMenuItem : NSMenuItem

@property (nonatomic, readonly) NSString    *selectedBSDPortName;

- (instancetype) initWithTitle:(NSString *)aString port:(NSString *) port;

@end
