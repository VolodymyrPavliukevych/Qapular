//
//  QCCFixItViewController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFixItViewController.h"

@interface QCCFixItViewController () {

    NSArray *_fixItArray;
}

@end

@implementation QCCFixItViewController


- (instancetype)initWithFixIts:(NSArray *) fixIts {
    self = [super init];

    if (self) {
        _fixItArray = fixIts;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, 400, 30 * [_fixItArray count]);
    
}

@end
