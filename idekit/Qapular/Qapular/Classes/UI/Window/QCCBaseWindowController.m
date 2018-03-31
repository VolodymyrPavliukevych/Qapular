//
//  QCCBaseWindowController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCBaseWindowController.h"

@interface QCCBaseWindowController ()

@end

@implementation QCCBaseWindowController
+ (instancetype)initFromDefaultWindowNib {
    NSString *nibName = [[self class] interfaceNibName];
    return [[[self class] alloc] initWithWindowNibName:nibName];
    
}

+ (NSString *) interfaceNibName {
    return NSStringFromClass([self class]);
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
}

@end
