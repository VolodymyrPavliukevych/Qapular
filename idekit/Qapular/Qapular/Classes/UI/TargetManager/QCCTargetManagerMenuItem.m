//
//  QCCTargetManagerMenuItem.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTargetManagerMenuItem.h"

@interface QCCTargetManagerMenuItem()
@end

@implementation QCCTargetManagerMenuItem

- (instancetype) initWithTitle:(NSString *)aString port:(NSString *) port {
    self = [super initWithTitle:aString action:nil keyEquivalent:@""];
    if (self) {
        _selectedBSDPortName = port;
        
    }
    
    return self;
    
}

@end
