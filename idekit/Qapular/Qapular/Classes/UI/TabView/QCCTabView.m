//
//  QCCTabView.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCTabView.h"
#import "QCCButton.h"

@interface QCCTabView() {
}

@end



@implementation QCCTabView
- (void) loadButtonsRelation {
}

-(void)awakeFromNib {
    [self loadButtonsRelation];
}

- (void) reselectButton:(QCCButton *) button {
    for (QCCButton *tabButton in _tabViewButtons)
        tabButton.state = (button == tabButton ? QCCButtonStateOn : QCCButtonStateOff);
}

- (IBAction) tabButtonAction:(QCCButton *)sender {
    [self reselectButton:sender];
    NSInteger index = [_tabViewButtons indexOfObject:sender];
    [self selectTabViewItemAtIndex:index];
}

@end
