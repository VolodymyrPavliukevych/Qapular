//
//  QCCSerialWindowController.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavlyukevich on 5/22/16.
//  Copyright © Volodymyr Pavliukevych 2014. All rights reserved.
//

#import "QCCSerialWindowController.h"
#import <QCCTargetManagerKit/QCCTargetManagerKit.h>

@interface QCCSerialWindowController ()
@property (nonatomic, strong) QCCTargetManager  *targetManager;
@end

@implementation QCCSerialWindowController
-(id)awakeAfterUsingCoder:(NSCoder *)aDecoder {

    return [super awakeAfterUsingCoder:aDecoder];
}

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _targetManager = [QCCTargetManager defaultManager];
    }
    return self;
}

-(NSViewController *)contentViewController {
    return _targetManager.serialConsoleViewController;
}


- (void)windowDidLoad {
    [super windowDidLoad];
}



@end
