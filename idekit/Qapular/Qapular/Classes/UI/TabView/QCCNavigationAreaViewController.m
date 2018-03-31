//
//  QCCLeftSideTabViewController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCNavigationAreaViewController.h"
#import "QCCButton.h"


@interface QCCNavigationAreaViewController() {

    IBOutlet QCCButton   *_filesButton;
    IBOutlet QCCButton   *_targetButton;
    IBOutlet QCCButton   *_searchButton;
    
}
@end

@implementation QCCNavigationAreaViewController

- (void) loadButtonsRelation {
    
    _tabViewButtons = @[_filesButton];//, _targetButton, _searchButton];
    _filesButton.state = QCCButtonStateOn;
    [self updateButtonAppearance];
}

-(void)setThemaManagerDataSource:(id<QCCThemaManagerDataSource>)themaManagerDataSource {
    _themaManagerDataSource = themaManagerDataSource;
    [self updateButtonAppearance];
}


- (void) updateButtonAppearance {
    if ([_themaManagerDataSource respondsToSelector:@selector(themaManager)])
        for (QCCButton *button in _tabViewButtons) {
            
            button.tintColor = [[_themaManagerDataSource themaManager] iconTintColor];
            button.selectedTintColor = [[_themaManagerDataSource themaManager] iconSelectedTintColor];
        }
}
#pragma mark - Notifications
- (void) subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themaManagerReplaced)
                                                 name:QCCThemaManagerReplacedNotification
                                               object:nil];
}

- (void) unsubscribe {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) themaManagerReplaced {
    [self updateButtonAppearance];
}


@end
