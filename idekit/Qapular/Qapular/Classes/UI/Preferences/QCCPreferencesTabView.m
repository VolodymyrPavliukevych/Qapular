//
//  QCCPreferencesTabView.m
//  Qapular
//
//  Created by Volodymyr Pavlyukevich on 5/16/16.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCPreferencesTabView.h"

@implementation QCCPreferencesTabView

-(void)setDataSource:(id<QCCPreferencesTabViewDataSource>)dataSource {
    _dataSource = dataSource;
    [_dataSource setTabView:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSTabViewItem *item in [self tabViewItems]) {
            [self removeTabViewItem:item];
        }
        NSUInteger numberOfTabViewItems = [self.dataSource numberOfTabViewItemsForTabView:self];
        for (NSUInteger index = 0; index < numberOfTabViewItems; index++) {
            NSTabViewItem *item = [self.dataSource tabView:self tabViewItemForIndex:index];
            if (item) {
                [self addTabViewItem:item];
            }
        }

    });
}


@end
